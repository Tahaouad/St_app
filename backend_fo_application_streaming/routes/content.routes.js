const express = require('express');
const router = express.Router();
const contentController = require('../controllers/content.controller');

// === DÉCOUVERTE (Routes publiques) ===
router.get('/search', contentController.search);
router.get('/popular', contentController.getPopular);
router.get('/trending', contentController.getTrending);
router.get('/top-rated', contentController.getTopRated);
router.get('/upcoming', contentController.getUpcoming);

// === GENRES ===
router.get('/genres', contentController.getGenres);
router.get('/genres/:genreId/discover', contentController.discoverByGenre);

// === DÉTAILS ===
router.get('/movie/:id', contentController.getMovieDetails);
router.get('/tv/:id', contentController.getTVDetails);
router.get('/tv/:tvId/season/:seasonNumber', contentController.getSeasonDetails);
router.get('/tv/:tvId/season/:seasonNumber/episode/:episodeNumber', contentController.getEpisodeDetails);

// === STREAMING ===
router.get('/stream/:type/:id', contentController.getStreamUrl);

module.exports = router;
