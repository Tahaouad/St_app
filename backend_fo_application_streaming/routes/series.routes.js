const express = require('express');
const router = express.Router();
const seriesController = require('../controllers/series.controller');
const authMiddleware = require('../middlewares/authMiddleware');

// Public routes
router.get('/', seriesController.getAllSeries);
router.get('/featured', seriesController.getFeaturedSeries);
router.get('/popular', seriesController.getPopularSeries);
router.get('/:id', seriesController.getSeriesById);
router.get('/:seriesId/seasons/:seasonId', seriesController.getSeasonById);
router.get('/:seriesId/seasons/:seasonId/episodes/:episodeId', seriesController.getEpisodeById);

module.exports = router;