const express = require('express');
const router = express.Router();
const userContentController = require('../controllers/user-content.controller');
const authMiddleware = require('../middlewares/authMiddleware');

// All routes require authentication
router.use(authMiddleware);

// Favorites
router.get('/favorites', userContentController.getUserFavorites);
router.post('/favorites', userContentController.addToFavorites);
router.delete('/favorites/:id', userContentController.removeFromFavorites);

// Ratings
router.post('/ratings', userContentController.addRating);

// Watch History
router.get('/history', userContentController.getWatchHistory);
router.post('/history', userContentController.updateWatchHistory);

module.exports = router;    