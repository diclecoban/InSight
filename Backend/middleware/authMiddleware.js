const crypto = require('crypto');
const pool = require('../config/db');

const hashToken = (token) => crypto.createHash('sha256').update(token).digest('hex');
const createToken = () => crypto.randomBytes(32).toString('hex');
const SESSION_TTL_MS = 30 * 24 * 60 * 60 * 1000;

exports.requireAuth = async (req, res, next) => {
    try {
        const authorization = req.headers.authorization;

        if (typeof authorization !== 'string') {
            return res.status(401).json({ error: 'Unauthorized.' });
        }

        const [scheme, token, extra] = authorization.trim().split(/\s+/);

        if (extra || scheme !== 'Bearer' || !token) {
            return res.status(401).json({ error: 'Unauthorized.' });
        }

        const tokenHash = hashToken(token);
        const result = await pool.query(
            `
            SELECT users.id, users.email
            FROM auth_sessions
            JOIN users ON users.id = auth_sessions."userID"
            WHERE auth_sessions.auth_token_hash = $1
              AND auth_sessions.expires_at > NOW()
            LIMIT 1
            `,
            [tokenHash]
        );

        if (result.rows.length === 0) {
            await pool.query(
                'DELETE FROM auth_sessions WHERE auth_token_hash = $1 AND expires_at <= NOW()',
                [tokenHash]
            );
            return res.status(401).json({ error: 'Unauthorized.' });
        }

        req.user = {
            id: result.rows[0].id,
            email: result.rows[0].email
        };

        return next();
    } catch (err) {
        return next(err);
    }
};

exports.requireMatchingUser = (req, res, next) => {
    const authenticatedUserID = req.user && req.user.id;
    const requestedUserID = req.params.userID ?? req.body.userID ?? req.body.userId;

    if (!authenticatedUserID || String(authenticatedUserID) !== String(requestedUserID)) {
        return res.status(403).json({ error: 'Forbidden.' });
    }

    return next();
};

exports.refreshSession = async (req, res) => {
    try {
        const refreshToken = String(req.body.refreshToken || '').trim();

        if (!refreshToken) {
            return res.status(401).json({ error: 'Invalid refresh token.' });
        }

        const authToken = createToken();
        const newRefreshToken = createToken();

        const result = await pool.query(
            `
            UPDATE auth_sessions AS session
            SET auth_token_hash = $2,
                refresh_token_hash = $3,
                expires_at = $4
            FROM users
            WHERE session."userID" = users.id
              AND session.refresh_token_hash = $1
              AND session.expires_at > NOW()
            RETURNING session."userID", users.email
            `,
            [
                hashToken(refreshToken),
                hashToken(authToken),
                hashToken(newRefreshToken),
                new Date(Date.now() + SESSION_TTL_MS)
            ]
        );

        if (result.rows.length === 0) {
            return res.status(401).json({ error: 'Invalid refresh token.' });
        }

        return res
            .set('Cache-Control', 'no-store')
            .set('Pragma', 'no-cache')
            .status(200)
            .json({
                userID: result.rows[0].userID,
                email: result.rows[0].email,
                authToken,
                refreshToken: newRefreshToken,
                message: 'Session refreshed successfully.'
            });
    } catch (err) {
        return res.status(500).json({ error: 'An unexpected error occurred on the server.' });
    }
};

module.exports.hashToken = hashToken;
module.exports.pool = pool;
