const pool = require('../config/db');

const mapSavedReview = (row) => ({
    id: row.id,
    productID: row.productID,
    productName: row.productName,
    status: row.status,
    savedAt: row.savedAt
});

const mapRecommendation = (row) => ({
    id: row.id,
    title: row.title,
    subtitle: row.subtitle
});

exports.getSavedReviews = async (req, res) => {
    try {
        const userID = req.user?.id || req.params.userID;

        const result = await pool.query(
            `
            SELECT
                sr.id,
                sr."productID" AS "productID",
                p.name AS "productName",
                sr.status,
                sr."savedAt"
            FROM saved_reviews sr
            JOIN products p ON p.id = sr."productID"
            WHERE sr."userID" = $1
            ORDER BY sr."savedAt" DESC
            `,
            [userID]
        );

        return res.status(200).json(result.rows.map(mapSavedReview));
    } catch (error) {
        console.error('Saved Reviews Error:', error);
        return res.status(500).json({ error: 'An unexpected error occurred on the server.' });
    }
};

exports.saveReview = async (req, res) => {
    try {
        const userID = req.user?.id || req.params.userID;
        const { productID, status } = req.body;

        if (!productID || !status) {
            return res.status(400).json({ error: 'productID and status are required.' });
        }

        const result = await pool.query(
            `
            INSERT INTO saved_reviews ("userID", "productID", status)
            VALUES ($1, $2, $3)
            ON CONFLICT ("userID", "productID")
            DO UPDATE SET status = EXCLUDED.status, "savedAt" = NOW()
            RETURNING id, "savedAt"
            `,
            [userID, productID, status]
        );

        return res.status(201).json({
            id: result.rows[0].id,
            productID,
            status,
            savedAt: result.rows[0].savedAt
        });
    } catch (error) {
        console.error('Save Review Error:', error);
        return res.status(500).json({ error: 'An unexpected error occurred on the server.' });
    }
};

exports.deleteSavedReview = async (req, res) => {
    try {
        const userID = req.user?.id || req.params.userID;
        const { reviewID } = req.params;

        const result = await pool.query(
            'DELETE FROM saved_reviews WHERE "userID" = $1 AND id = $2 RETURNING id',
            [userID, reviewID]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Saved review not found.' });
        }

        return res.status(204).send();
    } catch (error) {
        console.error('Delete Saved Review Error:', error);
        return res.status(500).json({ error: 'An unexpected error occurred on the server.' });
    }
};

exports.getRecommendations = async (req, res) => {
    try {
        const userID = req.user?.id || req.params.userID;

        const result = await pool.query(
            `
            SELECT id, title, subtitle
            FROM recommendations
            WHERE "userID" IS NULL OR "userID" = $1
            ORDER BY "createdAt" DESC
            LIMIT 10
            `,
            [userID]
        );

        return res.status(200).json(result.rows.map(mapRecommendation));
    } catch (error) {
        console.error('Recommendations Error:', error);
        return res.status(500).json({ error: 'An unexpected error occurred on the server.' });
    }
};
