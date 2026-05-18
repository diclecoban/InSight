const express = require('express');
const router = express.Router();
const scanController = require('../controllers/scanController');
const { requireAuth } = require('../middleware/authMiddleware');

const requireAuthForSavedScan = (req, res, next) => {
    if (!req.body?.userID && !req.body?.userId && !req.headers.authorization) {
        return next();
    }

    return requireAuth(req, res, (err) => {
        if (err) {
            return next(err);
        }

        req.body.userID = req.user.id;
        return next();
    });
};

router.post('/analyze', requireAuthForSavedScan, scanController.analyzeBarcode);

module.exports = router;
