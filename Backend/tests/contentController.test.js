const test = require('node:test');
const assert = require('node:assert/strict');
const {
    createQueryQueue,
    createResponse,
    loadControllerWithPool
} = require('./controllerTestUtils');

const contentControllerPath = '../controllers/contentController';

test('getSavedReviews returns saved reviews ordered by the controller query', async () => {
    const savedAt = new Date('2026-05-27T12:00:00.000Z');
    const pool = {
        query: createQueryQueue([
            {
                rows: [{
                    id: '55555555-5555-4555-8555-555555555555',
                    productName: 'Hydrating Cleanser',
                    status: 'safe',
                    savedAt
                }]
            }
        ])
    };
    const contentController = loadControllerWithPool(contentControllerPath, pool);
    const req = {
        params: {
            userID: 'user-id'
        }
    };
    const res = createResponse();

    await contentController.getSavedReviews(req, res);

    assert.equal(res.statusCode, 200);
    assert.deepEqual(res.body, [{
        id: '55555555-5555-4555-8555-555555555555',
        productName: 'Hydrating Cleanser',
        status: 'safe',
        savedAt
    }]);
});

test('saveReview validates required body fields', async () => {
    const pool = {
        query: async () => {
            assert.fail('database should not be called for invalid payloads');
        }
    };
    const contentController = loadControllerWithPool(contentControllerPath, pool);
    const req = {
        params: {
            userID: 'user-id'
        },
        body: {
            productID: '',
            status: 'safe'
        }
    };
    const res = createResponse();

    await contentController.saveReview(req, res);

    assert.equal(res.statusCode, 400);
    assert.deepEqual(res.body, { error: 'productID and status are required.' });
});

test('saveReview inserts or updates a saved review', async () => {
    const savedAt = new Date('2026-05-27T12:00:00.000Z');
    const pool = {
        query: createQueryQueue([
            {
                rows: [{
                    id: '66666666-6666-4666-8666-666666666666',
                    savedAt
                }]
            }
        ])
    };
    const contentController = loadControllerWithPool(contentControllerPath, pool);
    const req = {
        params: {
            userID: 'user-id'
        },
        body: {
            productID: 'product-id',
            status: 'mostlySafe'
        }
    };
    const res = createResponse();

    await contentController.saveReview(req, res);

    assert.equal(res.statusCode, 201);
    assert.deepEqual(res.body, {
        id: '66666666-6666-4666-8666-666666666666',
        productID: 'product-id',
        status: 'mostlySafe',
        savedAt
    });
});

test('getRecommendations returns personalized and global recommendations', async () => {
    const pool = {
        query: createQueryQueue([
            {
                rows: [{
                    id: '77777777-7777-4777-8777-777777777777',
                    title: 'Ingredient of the Day',
                    subtitle: 'Glycerin'
                }]
            }
        ])
    };
    const contentController = loadControllerWithPool(contentControllerPath, pool);
    const req = {
        params: {
            userID: 'user-id'
        }
    };
    const res = createResponse();

    await contentController.getRecommendations(req, res);

    assert.equal(res.statusCode, 200);
    assert.deepEqual(res.body, [{
        id: '77777777-7777-4777-8777-777777777777',
        title: 'Ingredient of the Day',
        subtitle: 'Glycerin'
    }]);
});
