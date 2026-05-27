const pool = require('../config/db');
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const { sendVerificationEmail } = require('../services/emailService');

const createToken = () => crypto.randomBytes(32).toString('hex');
// Amaç: Raw token’ı DB’ye koymadan önce SHA-256 ile hashlemek. Böylece DB sızarsa gerçek token’lar görülmez.
const hashToken = (token) => crypto.createHash('sha256').update(token).digest('hex'); 
const normalizeEmail = (email) => (
    typeof email === 'string' ? email.trim().toLowerCase() : ''
);
const normalizeVerificationCode = (code) => String(code ?? '').trim();
const normalizeGender = (gender) => {
    const normalized = String(gender ?? '').trim().toLowerCase();

    if (normalized === 'non-binary' || normalized === 'non binary') {
        return 'other';
    }

    return normalized;
};
const isBlank = (value) => (
    typeof value !== 'string' || value.trim().length === 0
);
const validateRegistrationBody = (body) => {
    const errors = [];
    const normalizedEmail = normalizeEmail(body.email);
    const normalizedGender = normalizeGender(body.gender);
    const age = Number(body.age);

    if (!normalizedEmail) {
        errors.push({ field: 'email', message: 'email is required.' });
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalizedEmail)) {
        errors.push({ field: 'email', message: 'email must be a valid email address.' });
    }

    if (isBlank(body.password)) {
        errors.push({ field: 'password', message: 'password is required.' });
    } else if (body.password.length < 6) {
        errors.push({ field: 'password', message: 'password must be at least 6 characters.' });
    }

    if (isBlank(body.firstName)) {
        errors.push({ field: 'firstName', message: 'firstName is required.' });
    }

    if (isBlank(body.lastName)) {
        errors.push({ field: 'lastName', message: 'lastName is required.' });
    }

    if (body.age === undefined || body.age === null || body.age === '') {
        errors.push({ field: 'age', message: 'age is required.' });
    } else if (!Number.isInteger(age) || age < 12 || age > 120) {
        errors.push({ field: 'age', message: 'age must be an integer between 12 and 120.' });
    }

    if (!normalizedGender) {
        errors.push({ field: 'gender', message: 'gender is required.' });
    } else if (!['male', 'female', 'other'].includes(normalizedGender)) {
        errors.push({ field: 'gender', message: 'gender must be one of: male, female, other.' });
    }

    if (isBlank(body.skinType)) {
        errors.push({ field: 'skinType', message: 'skinType is required.' });
    }

    if (body.allergies !== undefined && !Array.isArray(body.allergies)) {
        errors.push({ field: 'allergies', message: 'allergies must be an array of strings.' });
    } else if (Array.isArray(body.allergies) && body.allergies.some((allergy) => typeof allergy !== 'string')) {
        errors.push({ field: 'allergies', message: 'allergies must only contain strings.' });
    }

    return {
        errors,
        normalizedEmail,
        normalizedGender,
        age
    };
};
const registrationDatabaseError = (error) => {
    if (error.code === '23505' && error.constraint === 'users_email_key') {
        return {
            status: 400,
            body: {
                error: 'Registration validation failed.',
                details: [{ field: 'email', message: 'This email address is already registered.' }]
            }
        };
    }

    if (error.code === '23502') {
        return {
            status: 400,
            body: {
                error: 'Registration validation failed.',
                details: [{ field: error.column || 'unknown', message: `${error.column || 'A required field'} cannot be null.` }]
            }
        };
    }

    if (error.code === '23514') {
        const field = error.constraint === 'profiles_gender_check'
            ? 'gender'
            : error.constraint === 'profiles_age_check'
                ? 'age'
                : 'unknown';

        return {
            status: 400,
            body: {
                error: 'Registration validation failed.',
                details: [{ field, message: `Database constraint failed: ${error.constraint || 'unknown constraint'}.` }]
            }
        };
    }

    return null;
};
const SESSION_TTL_MS = 30 * 24 * 60 * 60 * 1000;

const createAuthSession = async (client, user, message) => {
    const authToken = createToken();
    const refreshToken = createToken();

    await client.query(
        `
        INSERT INTO auth_sessions ("userID", auth_token_hash, refresh_token_hash, expires_at)
        VALUES ($1, $2, $3, $4)
        `,
        [
            user.id,
            hashToken(authToken),
            hashToken(refreshToken),
            new Date(Date.now() + SESSION_TTL_MS)
        ]
    );

    return {
        userID: user.id,
        email: user.email,
        authToken,
        refreshToken,
        message
    };
};

const sendAuthResponse = (res, statusCode, body) => (
    res
        .set('Cache-Control', 'no-store')
        .set('Pragma', 'no-cache')
        .status(statusCode)
        .json(body)
);

exports.refresh = async (req, res) => {
    try {
        const refreshToken = String(req.body.refreshToken || '').trim();

        if (!refreshToken) {
            return sendAuthResponse(res, 401, { error: "Invalid refresh token." });
        }

        const authToken = createToken();
        const newRefreshToken = createToken();
        const expiresAt = new Date(Date.now() + SESSION_TTL_MS);

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
                expiresAt
            ]
        );

        if (result.rows.length === 0) {
            return sendAuthResponse(res, 401, { error: "Invalid refresh token." });
        }

        return sendAuthResponse(res, 200, {
            userID: result.rows[0].userID,
            email: result.rows[0].email,
            authToken,
            refreshToken: newRefreshToken,
            message: "Session refreshed successfully."
        });
    } catch (err) {
        console.error("Refresh Token Error:", err);
        return res.status(500).json({ error: "An unexpected error occurred on the server." });
    }
};

// 🎀 --- USER REGISTRATION --- 🎀 //

exports.register = async (req, res) => {
    let client;
    let transactionStarted = false;

    try {
        const { 
            email, 
            password, 
            firstName, 
            lastName, 
            gender,
            skinType, 
            allergies
        } = req.body; // Reads data sent from the frontend.
        const {
            errors,
            normalizedEmail,
            normalizedGender,
            age
        } = validateRegistrationBody(req.body);

        if (errors.length > 0) {
            return res.status(400).json({
                error: 'Registration validation failed.',
                details: errors
            });
        }

        client = await pool.connect();

        const saltRounds = 10;
        const passwordHash = await bcrypt.hash(password, saltRounds);
        
        const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
        const codeExpiresAt = new Date(Date.now() + 10 * 60 * 1000); 
        const allergiesArray = Array.isArray(allergies) ? allergies : [];

        await client.query('BEGIN');
        transactionStarted = true;

        const userInsertQuery = `
            INSERT INTO users (email, password_hash, verification_code, code_expires_at) 
            VALUES ($1, $2, $3, $4) 
            RETURNING id
        `;
        const userResult = await client.query(userInsertQuery, [
            normalizedEmail, 
            passwordHash, 
            verificationCode, 
            codeExpiresAt
        ]);
        
        const userId = userResult.rows[0].id;

        const profileInsertQuery = `
            INSERT INTO profiles ("userID", "firstName", "lastName", age, gender, "skinType", allergies) 
            VALUES ($1, $2, $3, $4, $5, $6, $7)
        `;
        await client.query(profileInsertQuery, [
            userId, 
            firstName, 
            lastName, 
            age,
            normalizedGender,
            skinType, 
            allergiesArray
        ]);

        console.log(`--------------------------------------------------`);
        console.log(`✅ NEW USER REGISTERED`);
        console.log(`📧 Email: ${normalizedEmail}`);
        console.log(`🔑 OTP: ${verificationCode}`);
        console.log(`--------------------------------------------------`);

        const authResponse = await createAuthSession(
            client,
            { id: userId, email: normalizedEmail },
            "Registration successful. Please verify your email."
        );

        await client.query('COMMIT');
        transactionStarted = false;

        sendVerificationEmail(normalizedEmail, verificationCode).catch((error) => {
            console.error("Verification Email Error:", error.message);
        });

        return sendAuthResponse(res, 201, authResponse);

    } catch (error) {
        if (client && transactionStarted) {
            await client.query('ROLLBACK');
        }

        const databaseError = registrationDatabaseError(error);
        if (databaseError) {
            return res.status(databaseError.status).json(databaseError.body);
        }

        console.error("Registration Error Details:", error);
        return res.status(500).json({
            error: "An unexpected error occurred on the server.",
            details: {
                code: error.code || 'unknown',
                message: error.message
            }
        });

    } finally {
        if (client) {
            client.release();
        }
    }
};

// 🎀 --- USER LOGIN --- 🎀 //

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const normalizedEmail = normalizeEmail(email);

        if (!normalizedEmail || !password) {
            return res.status(400).json({ error: "Email and password are required." });
        }

        const userResult = await pool.query(
            'SELECT id, email, password_hash, is_verified FROM users WHERE email = $1', 
            [normalizedEmail]
        );
        if (userResult.rows.length === 0) {
            return res.status(401).json({ error: "Email or password is incorrect." });
        }

        const user = userResult.rows[0];

        // bcrypt.compare hashes the incoming password and compares it with the database value.
        const isMatch = await bcrypt.compare(password, user.password_hash);

        if (!isMatch) {
            return res.status(401).json({ error: "Email or password is incorrect." });
        }

        if (!user.is_verified) {
            return res.status(403).json({ error: "Please verify your email before logging in." });
        }

        const authResponse = await createAuthSession(pool, user, "Login successful!");
        return sendAuthResponse(res, 200, authResponse);

    } catch (err) {
        console.error("Login Error:", err);
        res.status(500).json({ error: "An unexpected error occurred on the server." });
    }
};

// 🎀 --- OTP VERIFICATION --- 🎀 //

exports.verifyOTP = async (req, res) => {
    try {
        const { email, code } = req.body;
        const normalizedEmail = normalizeEmail(email);
        const verificationCode = normalizeVerificationCode(code);

        if (!normalizedEmail || !verificationCode) {
            return res.status(400).json({ error: "Email and verification code are required." });
        }

        const userResult = await pool.query(
            'SELECT id, email, verification_code, code_expires_at FROM users WHERE email = $1',
            [normalizedEmail]
        );

        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: "User not found." });
        }

        const user = userResult.rows[0];

        if (user.verification_code !== verificationCode) {
            return res.status(400).json({ error: "Invalid verification code." });
        }
        if (!user.code_expires_at || new Date() > user.code_expires_at) {
            return res.status(400).json({ error: "Verification code has expired." });
        }

        
        await pool.query(
            'UPDATE users SET is_verified = TRUE, verification_code = NULL, code_expires_at = NULL WHERE email = $1',
            [normalizedEmail]
        );

        const authResponse = await createAuthSession(pool, user, "Email verified successfully!");
        return sendAuthResponse(res, 200, authResponse);

    } catch (err) {
        console.error("OTP Error:", err);
        res.status(500).json({ error: "An error occurred during verification." });
    }
};

// 🎀 --- USER LOGOUT --- 🎀 //

exports.logout = async (req, res) => {
    try {
        const authorization = req.headers.authorization || '';
        const bearerToken = authorization.startsWith('Bearer ')
            ? authorization.slice('Bearer '.length).trim()
            : '';
        const authToken = String(req.body.authToken || bearerToken || '').trim();
        const refreshToken = String(req.body.refreshToken || '').trim();

        if (!authToken && !refreshToken) {
            return res.status(400).json({ error: "authToken or refreshToken is required." });
        }

        const conditions = [];
        const values = [];

        if (authToken) {
            values.push(hashToken(authToken));
            conditions.push(`auth_token_hash = $${values.length}`);
        }

        if (refreshToken) {
            values.push(hashToken(refreshToken));
            conditions.push(`refresh_token_hash = $${values.length}`);
        }

        const result = await pool.query(
            `DELETE FROM auth_sessions WHERE ${conditions.join(' OR ')} RETURNING id`,
            values
        );

        return res.status(200).json({
            message: result.rows.length > 0 ? "Logout successful." : "Session already expired."
        });
    } catch (err) {
        console.error("Logout Error:", err);
        return res.status(500).json({ error: "An unexpected error occurred on the server." });
    }
};
