const { Movie, Category, Genre, Media } = require('../models');
const { Op } = require('sequelize');

// Get all movies with optional filtering
const getMovies = async (req, res) => {
  try {
    const { 
      categoryId, 
      genreId, 
      search, 
      limit = 10, 
      offset = 0,
      sortBy = 'createdAt',
      order = 'DESC'
    } = req.query;
    
    let where = { isActive: true };
    if (categoryId) where.categoryId = categoryId;
    if (search) {
      where[Op.or] = [
        { title: { [Op.like]: `%${search}%` } },
        { description: { [Op.like]: `%${search}%` } }
      ];
    }
    
    let include = [
      { model: Category },
      { model: Genre },
      { model: Media, where: { type: 'poster', isDefault: true }, required: false }
    ];
    
    // Handle genre filtering with a separate query
    if (genreId) {
      include.push({
        model: Genre,
        where: { id: genreId },
        through: { attributes: [] }
      });
    }
    
    const movies = await Movie.findAndCountAll({
      where,
      include,
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [[sortBy, order]],
      distinct: true
    });
    
    res.status(200).json({
      count: movies.count,
      rows: movies.rows,
      totalPages: Math.ceil(movies.count / limit)
    });
  } catch (error) {
    console.error('Error fetching movies:', error);
    res.status(500).json({ message: "Error fetching movies", error: error.message });
  }
};

// Get featured movies
const getFeaturedMovies = async (req, res) => {
  try {
    const movies = await Movie.findAll({
      where: { 
        isActive: true,
        isFeatured: true 
      },
      include: [
        { model: Category },
        { model: Genre },
        { model: Media, where: { type: 'poster', isDefault: true }, required: false }
      ],
      limit: 10
    });
    
    res.status(200).json(movies);
  } catch (error) {
    console.error('Error fetching featured movies:', error);
    res.status(500).json({ message: "Error fetching featured movies", error: error.message });
  }
};

// Get a single movie by ID
const getMovieById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const movie = await Movie.findOne({
      where: { id, isActive: true },
      include: [
        { model: Category },
        { model: Genre },
        { model: Media }
      ]
    });
    
    if (!movie) {
      return res.status(404).json({ message: "Movie not found" });
    }
    
    // Update view count
    await movie.update({ viewCount: movie.viewCount + 1 });
    
    res.status(200).json(movie);
  } catch (error) {
    console.error('Error fetching movie:', error);
    res.status(500).json({ message: "Error fetching movie", error: error.message });
  }
};

// Get related movies (same genre or category)
const getRelatedMovies = async (req, res) => {
  try {
    const { id } = req.params;
    const { limit = 8 } = req.query;
    
    // Get the current movie to find related ones
    const currentMovie = await Movie.findByPk(id, {
      include: [{ model: Genre }]
    });
    
    if (!currentMovie) {
      return res.status(404).json({ message: "Movie not found" });
    }
    
    // Extract genre IDs from the current movie
    const genreIds = currentMovie.Genres.map(genre => genre.id);
    
    // Find related movies based on genres and category
    const relatedMovies = await Movie.findAll({
      where: {
        id: { [Op.ne]: id }, // Not the current movie
        isActive: true,
        [Op.or]: [
          { categoryId: currentMovie.categoryId }
          // We'll handle genre filtering with a separate include
        ]
      },
      include: [
        { model: Category },
        { 
          model: Genre,
          where: { id: { [Op.in]: genreIds } },
          through: { attributes: [] }
        },
        { model: Media, where: { type: 'poster', isDefault: true }, required: false }
      ],
      limit: parseInt(limit),
      order: [['viewCount', 'DESC']]
    });
    
    res.status(200).json(relatedMovies);
  } catch (error) {
    console.error('Error fetching related movies:', error);
    res.status(500).json({ message: "Error fetching related movies", error: error.message });
  }
};

// Get popular movies
const getPopularMovies = async (req, res) => {
  try {
    const { limit = 10 } = req.query;
    
    const movies = await Movie.findAll({
      where: { isActive: true },
      include: [
        { model: Category },
        { model: Genre },
        { model: Media, where: { type: 'poster', isDefault: true }, required: false }
      ],
      order: [['viewCount', 'DESC']],
      limit: parseInt(limit)
    });
    
    res.status(200).json(movies);
  } catch (error) {
    console.error('Error fetching popular movies:', error);
    res.status(500).json({ message: "Error fetching popular movies", error: error.message });
  }
};

module.exports = {
  getMovies,
  getFeaturedMovies,
  getMovieById,
  getRelatedMovies,
  getPopularMovies
};