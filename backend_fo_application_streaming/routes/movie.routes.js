const express = require('express');
const router = express.Router();
const movieController = require('../controllers/movie.controller');
const authMiddleware = require('../middlewares/authMiddleware');

// Public routes
router.get('/', movieController.getMovies);
router.get('/featured', movieController.getFeaturedMovies);
router.get('/popular', movieController.getPopularMovies);
router.get('/:id', movieController.getMovieById);
router.get('/:id/related', movieController.getRelatedMovies);

module.exports = router;