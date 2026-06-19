const test = require('node:test');
const assert = require('node:assert/strict');
const {
    createQueryQueue,
    createResponse,
    loadControllerWithPool
} = require('./controllerTestUtils');

const profileControllerPath = '../controllers/profileController';

const profileRow = {
    id: '44444444-4444-4444-8444-444444444444',
    firstName: 'Dicle',
    lastName: 'Coban',
    email: 'dicle@example.com',
    age: 30,
    gender: 'female',
    skinType: 'Dry',
    condition: null,
    sensitivity: 'High',
    allergies: ['Fragrance']
};

test('getProfile returns mapped profile data', async () => {
    const pool = {
        query: createQueryQueue([
            { rows: [profileRow] }
        ])
    };
    const profileController = loadControllerWithPool(profileControllerPath, pool);
    const req = {
        user: {
            id: profileRow.id
        },
        params: {
            userID: 'stale-client-user-id'
        }
    };
    const res = createResponse();

    await profileController.getProfile(req, res);

    assert.equal(res.statusCode, 200);
    assert.deepEqual(res.body, {
        id: profileRow.id,
        firstName: 'Dicle',
        lastName: 'Coban',
        email: 'dicle@example.com',
        age: 30,
        gender: 'female',
        skinType: 'Dry',
        condition: 'Not specified',
        sensitivity: 'High',
        allergies: ['Fragrance']
    });
});

test('getProfile returns 404 when profile is missing', async () => {
    const pool = {
        query: createQueryQueue([
            { rows: [] }
        ])
    };
    const profileController = loadControllerWithPool(profileControllerPath, pool);
    const req = {
        user: {
            id: 'missing-user'
        },
        params: {
            userID: 'stale-client-user-id'
        }
    };
    const res = createResponse();

    await profileController.getProfile(req, res);

    assert.equal(res.statusCode, 404);
    assert.deepEqual(res.body, { error: 'Profile not found.' });
});

test('updateProfile updates editable fields and returns the refreshed profile', async () => {
    const pool = {
        query: createQueryQueue([
            { rows: [{ userID: profileRow.id }] },
            { rows: [profileRow] }
        ])
    };
    const profileController = loadControllerWithPool(profileControllerPath, pool);
    const req = {
        user: {
            id: profileRow.id
        },
        params: {
            userID: 'stale-client-user-id'
        },
        body: {
            firstName: 'Dicle',
            skinType: 'Dry',
            allergies: ['Fragrance']
        }
    };
    const res = createResponse();

    await profileController.updateProfile(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.id, profileRow.id);
    assert.equal(res.body.firstName, 'Dicle');
});
