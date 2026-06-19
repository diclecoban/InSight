// Defines which URL runs which function.

const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { requireAuth } = require('../middleware/authMiddleware');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/verify-otp', authController.verifyOTP);
router.post('/refresh', authController.refresh);
router.post('/logout', authController.logout);
router.post('/email-change/request-current-code', requireAuth, authController.requestEmailChangeCurrentCode);
router.post('/email-change/verify-current-code', requireAuth, authController.verifyEmailChangeCurrentCode);
router.post('/email-change/confirm-new-code', requireAuth, authController.confirmEmailChangeNewCode);

module.exports = router;
