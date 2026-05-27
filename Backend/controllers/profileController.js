const pool = require('../config/db');

const mapProfile = (row) => ({
    id: row.id,
    firstName: row.firstName,
    lastName: row.lastName,
    email: row.email,
    age: Number(row.age ?? 0),
    skinType: row.skinType,
    condition: row.condition ?? 'Not specified',
    sensitivity: row.sensitivity ?? 'Not specified',
    allergies: row.allergies ?? []
});

exports.getProfile = async (req, res) => {
    try {
        const { userID } = req.params;

        const result = await pool.query(
            `
            SELECT
                u.id,
                u.email,
                p."firstName",
                p."lastName",
                p."skinType",
                COALESCE(p.condition, 'Not specified') AS condition,
                COALESCE(p.sensitivity, 'Not specified') AS sensitivity,
                COALESCE(p.allergies, ARRAY[]::text[]) AS allergies,
                p.age
            FROM users u
            JOIN profiles p ON p."userID" = u.id
            WHERE u.id = $1
            `,
            [userID]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Profile not found.' });
        }

        return res.status(200).json(mapProfile(result.rows[0]));
    } catch (error) {
        console.error('Get Profile Error:', error);
        return res.status(500).json({ error: 'An unexpected error occurred on the server.' });
    }
};

exports.updateProfile = async (req, res) => {
    try {
        const { userID } = req.params;
        const {
            firstName,
            lastName,
            age,
            gender,
            skinType,
            condition,
            sensitivity,
            allergies
        } = req.body;

        const result = await pool.query(
            `
            UPDATE profiles
            SET
                "firstName" = COALESCE($2, "firstName"),
                "lastName" = COALESCE($3, "lastName"),
                age = COALESCE($4, age),
                gender = COALESCE($5, gender),
                "skinType" = COALESCE($6, "skinType"),
                condition = COALESCE($7, condition),
                sensitivity = COALESCE($8, sensitivity),
                allergies = COALESCE($9, allergies)
            WHERE "userID" = $1
            RETURNING "userID"
            `,
            [
                userID,
                firstName,
                lastName,
                age,
                gender,
                skinType,
                condition,
                sensitivity,
                Array.isArray(allergies) ? allergies : null
            ]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Profile not found.' });
        }

        return exports.getProfile(req, res);
    } catch (error) {
        console.error('Update Profile Error:', error);
        return res.status(500).json({ error: 'An unexpected error occurred on the server.' });
    }
};
