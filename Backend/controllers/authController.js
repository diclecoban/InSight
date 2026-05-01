const pool = require('../config/db');
const bcrypt = require('bcrypt');

// 🎀 --- USER REGISTRATION --- 🎀 //

exports.register = async (req, res) => {
    const client = await pool.connect();

    try {
        const { 
            email, 
            password, 
            firstName, 
            lastName, 
            age, 
            skinType, 
            condition, 
            sensitivity, 
            allergies
        } = req.body;

        if (!email || !password || !firstName || !lastName) {
            return res.status(400).json({ 
                error: "Missing required fields: email, password, firstName, and lastName are mandatory." 
            });
        }
        if (password.length < 6) {
            return res.status(400).json({ 
                error: "Password is too short. Minimum 6 characters required." 
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
            email, 
            passwordHash, 
            verificationCode, 
            codeExpiresAt
        ]);
        
        const userId = userResult.rows[0].id;

        const profileInsertQuery = `
            INSERT INTO profiles ("userID", "firstName", "lastName", age, "skinType", condition, sensitivity, allergies) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        `;
        await client.query(profileInsertQuery, [
            userId, 
            firstName, 
            lastName, 
            age, 
            skinType, 
            condition, 
            sensitivity, 
            allergiesArray
        ]);

        await client.query('COMMIT');

        console.log(`--------------------------------------------------`);
        console.log(`✅ NEW USER REGISTERED`);
        console.log(`📧 Email: ${email}`);
        console.log(`🔑 OTP: ${verificationCode}`);
        console.log(`--------------------------------------------------`);

        return res.status(201).json({
            userID: userId,
            email: email,
            authToken: "temporary_access_token_will_be_jwt_later", // İleride buraya gerçek JWT gelecek
            refreshToken: "temporary_refresh_token_will_be_jwt_later",
            message: "Registration successful. Please verify your email."
        });

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

        if (!email || !password) {
            return res.status(400).json({ error: "Email and password are required." });
        }

        const userResult = await pool.query(
            'SELECT id, email, password_hash FROM users WHERE email = $1', 
            [email]
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

        // İleride buraya JWT (Token) eklenecek
        res.status(200).json({
            message: "Login successful!",
            user: {
                id: user.id,
                email: user.email
            }
        });

    } catch (err) {
        console.error("Login Error:", err);
        res.status(500).json({ error: "An unexpected error occurred on the server." });
    }
};

// 🎀 --- OTP VERIFICATION --- 🎀 //

exports.verifyOTP = async (req, res) => {
    try {
        const { email, code } = req.body;

        const userResult = await pool.query(
            'SELECT verification_code, code_expires_at FROM users WHERE email = $1',
            [email]
        );

        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: "User not found." });
        }

        const user = userResult.rows[0];

        if (user.verification_code !== code) {
            return res.status(400).json({ error: "Invalid verification code." });
        }
        if (new Date() > user.code_expires_at) {
            return res.status(400).json({ error: "Verification code has expired." });
        }

        
        await pool.query(
            'UPDATE users SET is_verified = TRUE, verification_code = NULL, code_expires_at = NULL WHERE email = $1',
            [email]
        );

        res.status(200).json({ message: "Email verified successfully!" });

    } catch (err) {
        console.error("OTP Error:", err);
        res.status(500).json({ error: "An error occurred during verification." });
    }
};