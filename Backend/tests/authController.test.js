const test = require('node:test');
const assert = require('node:assert/strict');
const bcrypt = require('bcrypt');
const {
    createQueryQueue,
    createResponse,
    loadControllerWithPool
} = require('./controllerTestUtils');

const authControllerPath = '../controllers/authController';
const emailServicePath = '../services/emailService';

test('register creates a user profile and returns an auth session', async () => {
    const userID = '11111111-1111-4111-8111-111111111111';
    const client = {
        query: createQueryQueue([
            { rows: [] },
            { rows: [{ id: userID }] },
            { rows: [] },
            { rows: [] },
            { rows: [] }
        ]),
        release() {}
    };
    const pool = {
        connect: async () => client
    };
    const authController = loadControllerWithPool(authControllerPath, pool, {
        [emailServicePath]: {
            sendVerificationEmail: async () => {}
        }
    });
    const req = {
        body: {
            email: 'Test@Example.com',
            password: 'secret123',
            firstName: 'Test',
            lastName: 'User',
            age: 30,
            gender: 'other',
            skinType: 'Oily',
            allergies: []
        }
    };
    const res = createResponse();

    const originalLog = console.log;
    console.log = () => {};

    try {
        await authController.register(req, res);
    } finally {
        console.log = originalLog;
    }

    assert.equal(res.statusCode, 201);
    assert.equal(res.body.userID, userID);
    assert.equal(res.body.email, 'test@example.com');
    assert.ok(res.body.authToken);
    assert.ok(res.body.refreshToken);
    assert.equal(res.headers['Cache-Control'], 'no-store');
});

test('login rejects invalid credentials without leaking account state', async () => {
    const pool = {
        query: createQueryQueue([
            { rows: [] }
        ])
    };
    const authController = loadControllerWithPool(authControllerPath, pool);
    const req = {
        body: {
            email: 'missing@example.com',
            password: 'secret123'
        }
    };
    const res = createResponse();

    await authController.login(req, res);

    assert.equal(res.statusCode, 401);
    assert.deepEqual(res.body, { error: 'Email or password is incorrect.' });
});

test('login returns an auth session for verified credentials', async () => {
    const userID = '22222222-2222-4222-8222-222222222222';
    const passwordHash = await bcrypt.hash('secret123', 4);
    const pool = {
        query: createQueryQueue([
            {
                rows: [{
                    id: userID,
                    email: 'login@example.com',
                    password_hash: passwordHash,
                    is_verified: true
                }]
            },
            { rows: [] }
        ])
    };
    const authController = loadControllerWithPool(authControllerPath, pool);
    const req = {
        body: {
            email: 'login@example.com',
            password: 'secret123'
        }
    };
    const res = createResponse();

    await authController.login(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.userID, userID);
    assert.equal(res.body.email, 'login@example.com');
    assert.ok(res.body.authToken);
    assert.ok(res.body.refreshToken);
});

test('refresh rotates the token pair', async () => {
    const userID = '33333333-3333-4333-8333-333333333333';
    const pool = {
        query: createQueryQueue([
            {
                rows: [{
                    userID,
                    email: 'refresh@example.com'
                }]
            }
        ])
    };
    const authController = loadControllerWithPool(authControllerPath, pool);
    const req = {
        body: {
            refreshToken: 'existing-refresh-token'
        }
    };
    const res = createResponse();

    await authController.refresh(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.userID, userID);
    assert.equal(res.body.email, 'refresh@example.com');
    assert.notEqual(res.body.refreshToken, req.body.refreshToken);
    assert.ok(res.body.authToken);
});

test('verifyOTP marks the user verified and returns an auth session', async () => {
    const userID = '88888888-8888-4888-8888-888888888888';
    const pool = {
        query: createQueryQueue([
            {
                rows: [{
                    id: userID,
                    email: 'otp@example.com',
                    verification_code: '123456',
                    code_expires_at: new Date(Date.now() + 60_000)
                }]
            },
            { rows: [] },
            { rows: [] }
        ])
    };
    const authController = loadControllerWithPool(authControllerPath, pool);
    const req = {
        body: {
            email: 'otp@example.com',
            code: '123456'
        }
    };
    const res = createResponse();

    await authController.verifyOTP(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.userID, userID);
    assert.equal(res.body.email, 'otp@example.com');
    assert.ok(res.body.authToken);
    assert.ok(res.body.refreshToken);
});
