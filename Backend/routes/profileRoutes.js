const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');
const { requireAuth } = require('../middleware/authMiddleware');

router.get('/:userID', requireAuth, profileController.getProfile);
router.patch('/:userID', requireAuth, profileController.updateProfile);

module.exports = router;
