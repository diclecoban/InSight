const test = require('node:test');
const assert = require('node:assert/strict');
const {
    createQueryQueue,
    createResponse,
    loadControllerWithPool
} = require('./controllerTestUtils');

const scanControllerPath = '../controllers/scanController';

test('analyzeBarcode returns a personalized scan result for an existing product', async () => {
    const scannedAt = new Date('2026-05-27T12:00:00.000Z');
    const product = {
        id: '99999999-9999-4999-8999-999999999999',
        name: 'Hydrating Cleanser',
        brand: 'InSight Demo',
        priceText: '$19.99',
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
