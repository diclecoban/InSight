const test = require('node:test');
const assert = require('node:assert/strict');
const {
    createQueryQueue,
    createResponse,
    loadControllerWithPool
} = require('./controllerTestUtils');

const scanControllerPath = '../controllers/scanController';
const openBeautyFactsServicePath = '../services/openBeautyFactsService';

test('analyzeBarcode returns a personalized scan result for an existing product', async () => {
    const scannedAt = new Date('2026-05-27T12:00:00.000Z');
    const product = {
        id: '99999999-9999-4999-8999-999999999999',
        name: 'Hydrating Cleanser',
        brand: 'InSight Demo',
        priceText: '$19.99',
        imageURL: null,
        barcode: '8691234567890'
    };
    const client = {
        query: createQueryQueue([
            { rows: [] },
            { rows: [product] },
            {
                rows: [
                    {
                        id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
                        name: 'Glycerin',
                        detail: 'A humectant that supports hydration.',
                        riskNote: 'Low risk for most skin types.',
                        riskLevel: 'low'
                    },
                    {
                        id: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
                        name: 'Fragrance',
                        detail: 'Used to adjust the scent profile.',
                        riskNote: 'Can trigger irritation in sensitive skin.',
                        riskLevel: 'high'
                    }
                ]
            },
            {
                rows: [{
                    id: 'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
                    source: 'barcode',
                    scannedAt
                }]
            },
            { rows: [] }
        ]),
        release() {}
    };
    const pool = {
        connect: async () => client
    };
    const scanController = loadControllerWithPool(scanControllerPath, pool);
    const req = {
        headers: {
            'x-scan-source': 'barcode',
            'accept-language': 'en-US'
        },
        body: {
            barcode: product.barcode
        },
        user: {
            id: 'user-id'
        }
    };
    const res = createResponse();

    await scanController.analyzeBarcode(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.id, 'cccccccc-cccc-4ccc-8ccc-cccccccccccc');
    assert.equal(res.body.product.id, product.id);
    assert.equal(res.body.source, 'barcode');
    assert.equal(res.body.safetyLevel, 'mostlySafe');
    assert.equal(res.body.ingredients.length, 2);
});

test('analyzeBarcode validates barcode input before writing scan data', async () => {
    let didQuery = false;
    const client = {
        query: async () => {
            didQuery = true;
            return { rows: [] };
        },
        release() {}
    };
    const pool = {
        connect: async () => client
    };
    const scanController = loadControllerWithPool(scanControllerPath, pool);
    const req = {
        headers: {
            'x-scan-source': 'barcode'
        },
        body: {
            barcode: ''
        }
    };
    const res = createResponse();

    await scanController.analyzeBarcode(req, res);

    assert.equal(res.statusCode, 400);
    assert.deepEqual(res.body, { error: 'barcode is required.' });
    assert.equal(didQuery, false);
});

test('analyzeBarcode imports a missing barcode from Open Beauty Facts', async () => {
    const scannedAt = new Date('2026-05-27T12:00:00.000Z');
    const product = {
        id: '99999999-9999-4999-8999-999999999999',
        name: 'Gentle Face Cream',
        brand: 'Demo Brand',
        priceText: '',
        imageURL: 'https://images.openbeautyfacts.org/demo.jpg',
        barcode: '3560070791460'
    };
    const ingredients = [
        {
            id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
            name: 'Aqua',
            detail: 'Ingredient listed by Open Beauty Facts.',
            riskNote: 'Risk classification is pending regulatory enrichment.',
            riskLevel: 'low'
        },
        {
            id: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
            name: 'Glycerin',
            detail: 'Ingredient listed by Open Beauty Facts.',
            riskNote: 'Risk classification is pending regulatory enrichment.',
            riskLevel: 'low'
        }
    ];
    const client = {
        query: createQueryQueue([
            { rows: [] },
            { rows: [] },
            { rows: [product] },
            { rows: [ingredients[0]] },
            { rows: [] },
            { rows: [ingredients[1]] },
            { rows: [] },
            { rows: ingredients },
            {
                rows: [{
                    id: 'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
                    source: 'barcode',
                    scannedAt
                }]
            },
            { rows: [] }
        ]),
        release() {}
    };
    const pool = {
        connect: async () => client
    };
    const scanController = loadControllerWithPool(scanControllerPath, pool, {
        [openBeautyFactsServicePath]: {
            classifyIngredient: (name) => ({
                detail: `Classified ${name}`,
                riskNote: `Risk note ${name}`,
                riskLevel: 'low'
            }),
            fetchProductByBarcode: async () => ({
                name: product.name,
                brand: product.brand,
                priceText: product.priceText,
                imageURL: product.imageURL,
                barcode: product.barcode,
                ingredients
            })
        }
    });
    const req = {
        headers: {
            'x-scan-source': 'barcode',
            'accept-language': 'en-US'
        },
        body: {
            barcode: product.barcode
        }
    };
    const res = createResponse();

    await scanController.analyzeBarcode(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.product.name, 'Gentle Face Cream');
    assert.equal(res.body.product.brand, 'Demo Brand');
    assert.equal(res.body.product.imageURL, 'https://images.openbeautyfacts.org/demo.jpg');
    assert.equal(res.body.safetyLevel, 'safe');
    assert.deepEqual(
        res.body.ingredients.map((ingredient) => ingredient.name),
        ['Aqua', 'Glycerin']
    );
});

test('analyzeBarcode returns 404 when a missing barcode is not in Open Beauty Facts', async () => {
    const client = {
        query: createQueryQueue([
            { rows: [] },
            { rows: [] },
            { rows: [] }
        ]),
        release() {}
    };
    const pool = {
        connect: async () => client
    };
    const scanController = loadControllerWithPool(scanControllerPath, pool, {
        [openBeautyFactsServicePath]: {
            classifyIngredient: (name) => ({
                detail: `Classified ${name}`,
                riskNote: `Risk note ${name}`,
                riskLevel: 'low'
            }),
            fetchProductByBarcode: async () => null
        }
    });
    const req = {
        headers: {
            'x-scan-source': 'barcode',
            'accept-language': 'en-US'
        },
        body: {
            barcode: '0000000000000'
        }
    };
    const res = createResponse();

    await scanController.analyzeBarcode(req, res);

    assert.equal(res.statusCode, 404);
    assert.deepEqual(res.body, { error: 'No result was found for this barcode.' });
});
