const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/category.controller');

// Public routes
router.get('/categories', categoryController.getAllCategories);
router.get('/genres', categoryController.getAllGenres);

module.exports = router;