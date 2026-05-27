const test = require('node:test');
const assert = require('node:assert/strict');
const {
    attachRequestID,
    applySecurityHeaders,
    applyNoStoreForPrivateResponses,
    validateClientHeaders
} = require('../middleware/headerMiddleware');

const createResponse = () => {
    const headers = {};

    return {
        headers,
        statusCode: 200,
        body: null,
        set(name, value) {
            headers[name] = value;
            return this;
        },
        status(code) {
            this.statusCode = code;
            return this;
        },
        json(payload) {
            this.body = payload;
            return this;
        }
    };
};

test('attachRequestID preserves a valid incoming request id', () => {
    const req = { headers: { 'x-request-id': 'ios-test-123' } };
    const res = createResponse();
    let didCallNext = false;

    attachRequestID(req, res, () => {
        didCallNext = true;
    });

    assert.equal(req.requestID, 'ios-test-123');
    assert.equal(res.headers['X-Request-ID'], 'ios-test-123');
    assert.equal(didCallNext, true);
});

test('applySecurityHeaders sets defensive response headers', () => {
    const req = {};
    const res = createResponse();

    applySecurityHeaders(req, res, () => {});

    assert.equal(res.headers['X-Content-Type-Options'], 'nosniff');
    assert.equal(res.headers['X-Frame-Options'], 'DENY');
    assert.equal(res.headers['Referrer-Policy'], 'no-referrer');
});

test('validateClientHeaders rejects an invalid client platform', () => {
    const req = {
        headers: {
            'x-client-platform': 'desktop'
        }
    };
    const res = createResponse();

    validateClientHeaders(req, res, () => {
        assert.fail('next should not be called for invalid headers');
    });

    assert.equal(res.statusCode, 400);
    assert.deepEqual(res.body, { error: 'Invalid X-Client-Platform header.' });
});

test('applyNoStoreForPrivateResponses marks private paths as non-cacheable', () => {
    const req = { path: '/profiles/user-id' };
    const res = createResponse();

    applyNoStoreForPrivateResponses(req, res, () => {});

    assert.equal(res.headers['Cache-Control'], 'no-store');
    assert.equal(res.headers.Pragma, 'no-cache');
});
