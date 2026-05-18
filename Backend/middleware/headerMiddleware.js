const crypto = require('crypto');

const REQUEST_ID_PATTERN = /^[a-zA-Z0-9._:-]{1,128}$/;
const API_VERSION_PATTERN = /^v?\d+$/;
const CLIENT_PLATFORM_PATTERN = /^(ios|android|web)$/;
const CLIENT_VERSION_PATTERN = /^[0-9A-Za-z.+_-]{1,32}$/;
const ACCEPT_LANGUAGE_PATTERN = /^[A-Za-z0-9,;= ._*-]{1,128}$/;
const SCAN_SOURCE_PATTERN = /^(barcode|ocr|manual|photo)$/;

const firstHeaderValue = (value) => Array.isArray(value) ? value[0] : value;
const isPrivatePath = (path) => (
    path === '/auth' ||
    path.startsWith('/auth/') ||
    path.startsWith('/profiles/') ||
    path.startsWith('/content/')
);

exports.attachRequestID = (req, res, next) => {
    const incomingRequestID = String(firstHeaderValue(req.headers['x-request-id']) || '').trim();
    const requestID = REQUEST_ID_PATTERN.test(incomingRequestID)
        ? incomingRequestID
        : crypto.randomUUID();

    req.requestID = requestID;
    res.set('X-Request-ID', requestID);

    return next();
};

exports.applySecurityHeaders = (req, res, next) => {
    res.set('X-Content-Type-Options', 'nosniff');
    res.set('Content-Security-Policy', "default-src 'none'; frame-ancestors 'none'");
    res.set('X-Frame-Options', 'DENY');
    res.set('Referrer-Policy', 'no-referrer');

    if (process.env.NODE_ENV === 'production') {
        res.set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
    }

    return next();
};

exports.applyNoStoreForPrivateResponses = (req, res, next) => {
    const path = req.path || req.originalUrl || '';
    const hasUserScopedScan = path.startsWith('/scan/') && Boolean(req.body && req.body.userID);

    if (isPrivatePath(path) || hasUserScopedScan) {
        res.set('Cache-Control', 'no-store');
        res.set('Pragma', 'no-cache');
    }

    return next();
};

exports.validateClientHeaders = (req, res, next) => {
    const apiVersion = firstHeaderValue(req.headers['x-api-version']);
    const clientPlatform = firstHeaderValue(req.headers['x-client-platform']);
    const clientVersion = firstHeaderValue(req.headers['x-client-version']);
    const acceptLanguage = firstHeaderValue(req.headers['accept-language']);
    const scanSource = firstHeaderValue(req.headers['x-scan-source']);

    if (apiVersion && !API_VERSION_PATTERN.test(String(apiVersion).trim())) {
        return res.status(400).json({ error: 'Invalid X-API-Version header.' });
    }

    if (clientPlatform && !CLIENT_PLATFORM_PATTERN.test(String(clientPlatform).trim().toLowerCase())) {
        return res.status(400).json({ error: 'Invalid X-Client-Platform header.' });
    }

    if (clientVersion && !CLIENT_VERSION_PATTERN.test(String(clientVersion).trim())) {
        return res.status(400).json({ error: 'Invalid X-Client-Version header.' });
    }

    if (acceptLanguage && !ACCEPT_LANGUAGE_PATTERN.test(String(acceptLanguage).trim())) {
        return res.status(400).json({ error: 'Invalid Accept-Language header.' });
    }

    if (scanSource && !SCAN_SOURCE_PATTERN.test(String(scanSource).trim().toLowerCase())) {
        return res.status(400).json({ error: 'Invalid X-Scan-Source header.' });
    }

    return next();
};
