// Defines which URL runs which function.

const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/verify-otp', authController.verifyOTP);
router.post('/refresh', authController.refresh);
router.post('/logout', authController.logout);

module.exports = router;
