const express = require('express');
const router = express.Router();
const userDataController = require('../controllers/userData.controller');
const authMiddleware = require('../middlewares/authMiddleware');

// Toutes les routes nécessitent une authentification
router.use(authMiddleware);

// === WATCHLIST ===
router.get('/watchlist', userDataController.getWatchlist);
router.post('/watchlist', userDataController.addToWatchlist);
router.delete('/watchlist/:id', userDataController.removeFromWatchlist);
router.get('/watchlist/check', userDataController.checkInWatchlist);

// === RATINGS ===
router.get('/ratings', userDataController.getUserRatings);
router.post('/ratings', userDataController.addRating);
router.get('/rating', userDataController.getUserRating);

// === WATCH HISTORY ===
router.get('/history', userDataController.getWatchHistory);
router.post('/history', userDataController.updateWatchHistory);
router.get('/progress', userDataController.getWatchProgress);
router.get('/continue-watching', userDataController.getContinueWatching);

module.exports = router;