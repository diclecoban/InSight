const assert = require('node:assert/strict');

const createResponse = () => {
    const headers = {};

    return {
        headers,
        statusCode: 200,
        body: null,
        sent: false,
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
        },
        send(payload) {
            this.body = payload;
            this.sent = true;
            return this;
        }
    };
};

const createQueryQueue = (handlers) => {
    const queue = [...handlers];

    return async (...args) => {
        const next = queue.shift();
        assert.ok(next, `Unexpected query: ${args[0]}`);

        if (typeof next === 'function') {
            return next(...args);
        }

        return next;
    };
};

const loadControllerWithPool = (controllerPath, pool, extraMocks = {}) => {
    const dbPath = require.resolve('../config/db');
    const resolvedControllerPath = require.resolve(controllerPath);

    delete require.cache[resolvedControllerPath];
    require.cache[dbPath] = {
        id: dbPath,
        filename: dbPath,
        loaded: true,
        exports: pool
    };

    for (const [modulePath, exports] of Object.entries(extraMocks)) {
        const resolvedPath = require.resolve(modulePath);
        require.cache[resolvedPath] = {
            id: resolvedPath,
            filename: resolvedPath,
            loaded: true,
            exports
        };
    }

    return require(controllerPath);
};

module.exports = {
    createQueryQueue,
    createResponse,
    loadControllerWithPool
};
