const DEFAULT_BASE_URL = 'https://world.openbeautyfacts.org';
const DEFAULT_TIMEOUT_MS = 5000;

const getConfig = () => ({
    baseURL: process.env.OPEN_BEAUTY_FACTS_BASE_URL || DEFAULT_BASE_URL,
    timeoutMs: Number(process.env.OPEN_BEAUTY_FACTS_TIMEOUT_MS || DEFAULT_TIMEOUT_MS),
    userAgent: process.env.OPEN_BEAUTY_FACTS_USER_AGENT || 'InSight/1.0 (contact@example.com)'
});

const cleanText = (value) => String(value || '').trim();

const cleanIngredientName = (value) => cleanText(value)
    .replace(/^[a-z]{2}:/i, '')
    .replace(/[-_]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

const ingredientRiskRules = [
    {
        level: 'high',
        patterns: [/fragrance/i, /parfum/i, /perfume/i, /methylisothiazolinone/i, /methylchloroisothiazolinone/i],
        detail: 'A common cosmetic sensitizer group.',
        riskNote: 'Can trigger irritation or allergic reactions, especially on sensitive skin.'
    },
    {
        level: 'medium',
        patterns: [/alcohol denat/i, /^alcohol$/i, /ethanol/i, /sodium lauryl sulfate/i, /\bsls\b/i],
        detail: 'A functional ingredient that may be drying or irritating for some users.',
        riskNote: 'May be irritating for dry, sensitive, or barrier-damaged skin.'
    },
    {
        level: 'medium',
        patterns: [/methylparaben/i, /propylparaben/i, /butylparaben/i, /ethylparaben/i, /paraben/i],
        detail: 'A preservative group used to reduce microbial growth.',
        riskNote: 'Usually regulated in cosmetics, but some users prefer to avoid it.'
    },
    {
        level: 'low',
        patterns: [/glycerin/i, /aqua/i, /water/i, /hyaluronic/i, /niacinamide/i, /panthenol/i, /tocopherol/i],
        detail: 'A commonly used cosmetic ingredient.',
        riskNote: 'Low risk for most users.'
    }
];

const classifyIngredient = (name) => {
    const normalizedName = cleanIngredientName(name);
    const match = ingredientRiskRules.find((rule) => (
        rule.patterns.some((pattern) => pattern.test(normalizedName))
    ));

    if (match) {
        return {
            detail: match.detail,
            riskNote: match.riskNote,
            riskLevel: match.level
        };
    }

    return {
        detail: 'Ingredient listed by Open Beauty Facts.',
        riskNote: 'No specific warning is currently attached to this ingredient.',
        riskLevel: 'low'
    };
};

const uniqueIngredients = (values) => {
    const seen = new Set();
    const ingredients = [];

    for (const value of values) {
        const name = cleanIngredientName(value);
        const key = name.toLowerCase();

        if (!name || seen.has(key)) {
            continue;
        }

        seen.add(key);
        ingredients.push({
            name,
            ...classifyIngredient(name)
        });
    }

    return ingredients;
};

const ingredientsFromText = (text) => cleanText(text)
    .split(/[,;•\n]/)
    .map((entry) => entry.trim())
    .filter(Boolean);

const mapProduct = (barcode, payload) => {
    if (!payload || payload.status !== 1 || !payload.product) {
        return null;
    }

    const product = payload.product;
    const ingredientNames = [];

    if (Array.isArray(product.ingredients)) {
        ingredientNames.push(...product.ingredients.map((ingredient) => ingredient.text));
    }

    if (Array.isArray(product.ingredients_tags)) {
        ingredientNames.push(...product.ingredients_tags);
    }

    ingredientNames.push(...ingredientsFromText(
        product.ingredients_text_en || product.ingredients_text || product.ingredients_text_fr
    ));

    return {
        name: cleanText(product.product_name) || cleanText(product.generic_name) || 'Scanned Product',
        brand: cleanText(product.brands).split(',')[0].trim() || 'Unknown',
        priceText: '',
        barcode,
        imageURL: cleanText(product.image_front_url) || cleanText(product.image_url) || null,
        ingredients: uniqueIngredients(ingredientNames)
    };
};

const fetchProductByBarcode = async (barcode) => {
    const { baseURL, timeoutMs, userAgent } = getConfig();
    const fields = [
        'code',
        'product_name',
        'generic_name',
        'brands',
        'image_url',
        'image_front_url',
        'ingredients',
        'ingredients_tags',
        'ingredients_text',
        'ingredients_text_en',
        'ingredients_text_fr'
    ].join(',');
    const url = new URL(`/api/v2/product/${encodeURIComponent(barcode)}.json`, baseURL);
    url.searchParams.set('fields', fields);

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), timeoutMs);

    try {
        const response = await fetch(url, {
            headers: {
                Accept: 'application/json',
                'User-Agent': userAgent
            },
            signal: controller.signal
        });

        if (!response.ok) {
            return null;
        }

        return mapProduct(barcode, await response.json());
    } catch (error) {
        if (error.name !== 'AbortError') {
            console.warn('Open Beauty Facts lookup failed:', error.message);
        }

        return null;
    } finally {
        clearTimeout(timeout);
    }
};

module.exports = {
    fetchProductByBarcode,
    classifyIngredient,
    mapProduct
};
