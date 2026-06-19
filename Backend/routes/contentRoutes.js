const express = require('express');
const router = express.Router();
const contentController = require('../controllers/contentController');
const { requireAuth } = require('../middleware/authMiddleware');

router.get('/:userID/saved-reviews', requireAuth, contentController.getSavedReviews);
router.post('/:userID/saved-reviews', requireAuth, contentController.saveReview);
router.delete('/:userID/saved-reviews/:reviewID', requireAuth, contentController.deleteSavedReview);
router.get('/:userID/recommendations', requireAuth, contentController.getRecommendations);

module.exports = router;
