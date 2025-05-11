const express = require('express');
const router = express.Router();
const { register, login, getProfile } = require('../controllers/auth.controller');
const authenticateToken = require('../middlewares/authMiddleware');
const verifyToken = require('../middlewares/authMiddleware');

router.post('/register', register);
router.post('/login', login);
router.get('/me', verifyToken, getProfile);

module.exports = router;
