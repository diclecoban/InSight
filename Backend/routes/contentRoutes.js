const express = require('express');
const router = express.Router();
const contentController = require('../controllers/contentController');
const { requireAuth, requireMatchingUser } = require('../middleware/authMiddleware');

router.get('/:userID/saved-reviews', requireAuth, requireMatchingUser, contentController.getSavedReviews);
router.post('/:userID/saved-reviews', requireAuth, requireMatchingUser, contentController.saveReview);
router.delete('/:userID/saved-reviews/:reviewID', requireAuth, requireMatchingUser, contentController.deleteSavedReview);
router.get('/:userID/recommendations', requireAuth, requireMatchingUser, contentController.getRecommendations);

module.exports = router;
