const pool = require('../config/db');
const {
    classifyIngredient,
    fetchProductByBarcode
} = require('../services/openBeautyFactsService');

const SCAN_SOURCES = new Set(['barcode', 'ocr', 'manual', 'photo']);
const SUPPORTED_LOCALES = new Set(['en', 'tr']);

const fallbackIngredients = [
    {
        name: 'Glycerin',
        detail: 'A humectant that supports hydration.',
        riskNote: 'Low risk for most skin types.',
        riskLevel: 'low'
    },
    {
        name: 'Fragrance',
        detail: 'Used to adjust the scent profile.',
        riskNote: 'Can trigger irritation in sensitive skin.',
        riskLevel: 'high'
    }
];

const ingredientTranslations = {
    tr: {
        Glycerin: {
            detail: 'Nem tutmaya destek olan bir humektandır.',
            riskNote: 'Çoğu cilt tipi için düşük risklidir.'
        },
        Fragrance: {
            detail: 'Ürünün koku profilini ayarlamak için kullanılır.',
            riskNote: 'Hassas ciltlerde tahrişi tetikleyebilir.'
        }
    }
};

const summaries = {
    en: (score) => `The product is ${Math.round(score * 100)}% safe.`,
    tr: (score) => `Ürün %${Math.round(score * 100)} güvenli.`
};

const getLocale = (acceptLanguage = '') => {
    const languages = String(acceptLanguage)
        .split(',')
        .map((entry) => entry.split(';')[0].trim().slice(0, 2).toLowerCase());

    return languages.find((language) => SUPPORTED_LOCALES.has(language)) || 'en';
};

const getScanSource = (value) => {
    const source = String(value || 'barcode').trim().toLowerCase();
    return SCAN_SOURCES.has(source) ? source : null;
};

const safetyFromScore = (score) => {
    if (score >= 0.8) return 'safe';
    if (score >= 0.5) return 'mostlySafe';
    return 'risky';
};

const calculateScore = (ingredients) => {
    if (ingredients.length === 0) return 0.7;

    const penalty = ingredients.reduce((total, ingredient) => {
        if (ingredient.riskLevel === 'high') return total + 0.25;
        if (ingredient.riskLevel === 'medium') return total + 0.12;
        return total;
    }, 0);

    return Math.max(0.05, Math.min(1, 1 - penalty));
};

const clampScore = (score) => Math.max(0.05, Math.min(1, score));

const normalizeText = (value) => String(value || '').trim().toLowerCase();

const getPersonalization = async (client, userID, ingredients) => {
    if (!userID) {
        return {
            scorePenalty: 0,
            allergyMatches: [],
            sensitiveSkinPenalty: false
        };
    }

    const profileResult = await client.query(
        `
        SELECT "skinType", sensitivity, COALESCE(allergies, ARRAY[]::text[]) AS allergies
        FROM profiles
        WHERE "userID" = $1
        `,
        [userID]
    );

    const profile = profileResult.rows[0];
    if (!profile) {
        return {
            scorePenalty: 0,
            allergyMatches: [],
            sensitiveSkinPenalty: false
        };
    }

    const ingredientNames = ingredients.map((ingredient) => normalizeText(ingredient.name));
    const allergyMatches = (profile.allergies || [])
        .map((allergy) => String(allergy).trim())
        .filter((allergy) => ingredientNames.includes(normalizeText(allergy)));
    const hasSensitiveSkin = [profile.skinType, profile.sensitivity]
        .map(normalizeText)
        .some((value) => value.includes('sensitive') || value.includes('hassas') || value.includes('high'));
    const hasHigherRiskIngredient = ingredients.some((ingredient) => (
        ingredient.riskLevel === 'high' || ingredient.riskLevel === 'medium'
    ));

    return {
        scorePenalty: Math.min(0.4, allergyMatches.length * 0.22 + (hasSensitiveSkin && hasHigherRiskIngredient ? 0.1 : 0)),
        allergyMatches,
        sensitiveSkinPenalty: hasSensitiveSkin && hasHigherRiskIngredient
    };
};

const personalizedSummary = (score, locale, personalization) => {
    const baseSummary = summaries[locale](score);

    if (personalization.allergyMatches.length > 0) {
        const ingredients = personalization.allergyMatches.join(', ');
        return locale === 'tr'
            ? `${baseSummary} Profilindeki alerji bilgisi nedeniyle ${ingredients} için ekstra dikkat önerilir.`
            : `${baseSummary} Your profile flags ${ingredients}, so extra caution is recommended.`;
    }

    if (personalization.sensitiveSkinPenalty) {
        return locale === 'tr'
            ? `${baseSummary} Hassas cilt profili nedeniyle riskli içerikler skora yansıtıldı.`
            : `${baseSummary} Your sensitive-skin profile was included in the score.`;
    }

    return baseSummary;
};

const enrichIngredient = (ingredient) => {
    const classification = classifyIngredient(ingredient.name);
    const hasSpecificDetail = ingredient.detail &&
        !ingredient.detail.includes('Open Beauty Facts') &&
        !ingredient.detail.includes('pending regulatory');
    const hasSpecificRiskNote = ingredient.riskNote &&
        !ingredient.riskNote.includes('pending regulatory') &&
        !ingredient.riskNote.includes('No specific warning');

    return {
        ...ingredient,
        detail: hasSpecificDetail ? ingredient.detail : classification.detail,
        riskNote: hasSpecificRiskNote ? ingredient.riskNote : classification.riskNote,
        riskLevel: classification.riskLevel
    };
};

const localizeIngredient = (ingredient, locale) => {
    const translation = ingredientTranslations[locale]?.[ingredient.name];

    return {
        id: ingredient.id,
        name: ingredient.name,
        detail: translation?.detail || ingredient.detail,
        riskNote: translation?.riskNote || ingredient.riskNote,
        riskLevel: ingredient.riskLevel
    };
};

const mapScanResult = (scan, product, ingredients, score, locale, personalization) => {
    const safetyLevel = safetyFromScore(score);

    return {
        id: scan.id,
        product: {
            id: product.id,
            name: product.name,
            brand: product.brand,
            priceText: product.priceText,
            imageURL: product.imageURL || null,
            barcode: product.barcode
        },
        source: scan.source,
        score,
        safetyLevel,
        summary: personalizedSummary(score, locale, personalization),
        ingredients: ingredients.map((ingredient) => localizeIngredient(ingredient, locale)),
        scannedAt: scan.scannedAt
    };
};

const insertProductIngredients = async (client, productID, ingredients) => {
    const inserted = [];

    for (const [index, ingredient] of ingredients.entries()) {
        const ingredientResult = await client.query(
            `
            INSERT INTO ingredients (name, detail, "riskNote", "riskLevel")
            VALUES ($1, $2, $3, $4)
            ON CONFLICT (name)
            DO UPDATE SET
                detail = EXCLUDED.detail,
                "riskNote" = EXCLUDED."riskNote",
                "riskLevel" = EXCLUDED."riskLevel"
            RETURNING id, name, detail, "riskNote", "riskLevel"
            `,
            [ingredient.name, ingredient.detail, ingredient.riskNote, ingredient.riskLevel]
        );

        const row = ingredientResult.rows[0];
        inserted.push(row);

        await client.query(
            `
            INSERT INTO product_ingredients ("productID", "ingredientID", position)
            VALUES ($1, $2, $3)
            ON CONFLICT ("productID", "ingredientID") DO NOTHING
            `,
            [productID, row.id, index + 1]
        );
    }

    return inserted;
};

const findOrCreateProduct = async (client, barcode) => {
    const existing = await client.query(
        'SELECT id, name, brand, "priceText", "imageURL", barcode FROM products WHERE barcode = $1',
        [barcode]
    );

    if (existing.rows.length > 0) {
        return existing.rows[0];
    }

    const openBeautyFactsProduct = await fetchProductByBarcode(barcode);
    if (!openBeautyFactsProduct) {
        return null;
    }

    const created = await client.query(
        `
        INSERT INTO products (name, brand, "priceText", "imageURL", barcode)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id, name, brand, "priceText", "imageURL", barcode
        `,
        [
            openBeautyFactsProduct.name,
            openBeautyFactsProduct.brand,
            openBeautyFactsProduct.priceText,
            openBeautyFactsProduct.imageURL,
            openBeautyFactsProduct.barcode
        ]
    );

    await insertProductIngredients(client, created.rows[0].id, openBeautyFactsProduct.ingredients);

    return created.rows[0];
};

const getProductIngredients = async (client, productID) => {
    const result = await client.query(
        `
        SELECT
            i.id,
            i.name,
            i.detail,
            i."riskNote",
            i."riskLevel"
        FROM product_ingredients pi
        JOIN ingredients i ON i.id = pi."ingredientID"
        WHERE pi."productID" = $1
        ORDER BY pi.position ASC
        `,
        [productID]
    );

    if (result.rows.length > 0) {
        return result.rows.map(enrichIngredient);
    }

    const inserted = await insertProductIngredients(client, productID, fallbackIngredients);
    return inserted.map(enrichIngredient);
};

exports.analyzeBarcode = async (req, res) => {
    const client = await pool.connect();

    try {
        const { barcode } = req.body;
        const userID = req.user?.id || null;
        const normalizedBarcode = String(barcode ?? '').trim();
        const scanSource = getScanSource(req.headers['x-scan-source']);
        const locale = getLocale(req.headers['accept-language']);

        if (!normalizedBarcode) {
            return res.status(400).json({ error: 'barcode is required.' });
        }

        if (!scanSource) {
            return res.status(400).json({ error: 'Invalid X-Scan-Source header.' });
        }

        await client.query('BEGIN');

        const product = await findOrCreateProduct(client, normalizedBarcode);
        if (!product) {
            await client.query('ROLLBACK');
            return res.status(404).json({ error: 'No result was found for this barcode.' });
        }

        const ingredients = await getProductIngredients(client, product.id);
        const personalization = await getPersonalization(client, userID, ingredients);
        const score = clampScore(calculateScore(ingredients) - personalization.scorePenalty);
        const safetyLevel = safetyFromScore(score);

        const scanResult = await client.query(
            `
            INSERT INTO scans ("userID", "productID", barcode, source, score, "safetyLevel")
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id, source, "scannedAt"
            `,
            [userID || null, product.id, normalizedBarcode, scanSource, score, safetyLevel]
        );

        await client.query('COMMIT');

        return res.status(200).json(mapScanResult(
            scanResult.rows[0],
            product,
            ingredients,
            score,
            locale,
            personalization
        ));
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Barcode Analysis Error:', error);
        return res.status(500).json({ error: 'An unexpected error occurred on the server.' });
    } finally {
        client.release();
    }
};
