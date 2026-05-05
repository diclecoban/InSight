const pool = require('../config/db');
const bcrypt = require('bcrypt');
const crypto = require('crypto');

const createToken = () => crypto.randomBytes(32).toString('hex');
const normalizeEmail = (email) => (
    typeof email === 'string' ? email.trim().toLowerCase() : ''
);
const normalizeVerificationCode = (code) => String(code ?? '').trim();

const buildAuthResponse = (user, message) => ({
    userID: user.id,
    email: user.email,
    authToken: createToken(),
    refreshToken: createToken(),
    message
});

// 🎀 --- USER REGISTRATION --- 🎀 //

exports.register = async (req, res) => {
    const client = await pool.connect();

    try {
        const { 
            email, 
            password, 
            firstName, 
            lastName, 
            birthDate,
            gender,
            skinType, 
            allergies
        } = req.body;
        const normalizedEmail = normalizeEmail(email);

        if (!normalizedEmail || !password || !firstName || !lastName || !birthDate || !gender || !skinType) {
            return res.status(400).json({ 
                error: "Missing required fields: email, password, firstName, lastName, birthDate, gender, and skinType are mandatory." 
            });
        }
        if (password.length < 6) {
            return res.status(400).json({ 
                error: "Password is too short. Minimum 6 characters required." 
            });
        }
        if (!/^\d{4}-\d{2}-\d{2}$/.test(birthDate)) {
            return res.status(400).json({
                error: "birthDate must be in yyyy-MM-dd format."
            });
        }

        const saltRounds = 10;
        const passwordHash = await bcrypt.hash(password, saltRounds);
        
        const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
        const codeExpiresAt = new Date(Date.now() + 10 * 60 * 1000); 
        const allergiesArray = Array.isArray(allergies) ? allergies : [];

        await client.query('BEGIN');

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
            INSERT INTO profiles ("userID", "firstName", "lastName", "birthDate", gender, "skinType", allergies) 
            VALUES ($1, $2, $3, $4, $5, $6, $7)
        `;
        await client.query(profileInsertQuery, [
            userId, 
            firstName, 
            lastName, 
            birthDate,
            gender,
            skinType, 
            allergiesArray
        ]);

        await client.query('COMMIT');

        console.log(`--------------------------------------------------`);
        console.log(`✅ NEW USER REGISTERED`);
        console.log(`📧 Email: ${normalizedEmail}`);
        console.log(`🔑 OTP: ${verificationCode}`);
        console.log(`--------------------------------------------------`);

        return res.status(201).json(buildAuthResponse(
            { id: userId, email: normalizedEmail },
            "Registration successful. Please verify your email."
        ));

    } catch (error) {
        await client.query('ROLLBACK');

        if (error.code === '23505') { 
            return res.status(400).json({ error: "This email address is already registered." });
        }

        console.error("Registration Error Details:", error);
        return res.status(500).json({ error: "An unexpected error occurred on the server." });

    } finally {
        client.release();
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

        // bcrypt.compare: Gelen şifreyi hashleyip veritabanındakiyle karşılaştırır
        const isMatch = await bcrypt.compare(password, user.password_hash);

        if (!isMatch) {
            return res.status(401).json({ error: "Email or password is incorrect." });
        }

        if (!user.is_verified) {
            return res.status(403).json({ error: "Please verify your email before logging in." });
        }

        return res.status(200).json(buildAuthResponse(user, "Login successful!"));

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

        res.status(200).json(buildAuthResponse(user, "Email verified successfully!"));

    } catch (err) {
        console.error("OTP Error:", err);
        res.status(500).json({ error: "An error occurred during verification." });
    }
};
