const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');
const { requireAuth, requireMatchingUser } = require('../middleware/authMiddleware');

router.get('/:userID', requireAuth, requireMatchingUser, profileController.getProfile);
router.patch('/:userID', requireAuth, requireMatchingUser, profileController.updateProfile);

module.exports = router;
