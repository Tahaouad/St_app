const { Series, Season, Episode, Category, Genre, Media } = require('../models');
const { Op } = require('sequelize');

// Get all series with optional filtering
const getAllSeries = async (req, res) => {
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
    
    // Handle genre filtering
    if (genreId) {
      include.push({
        model: Genre,
        where: { id: genreId },
        through: { attributes: [] }
      });
    }
    
    const series = await Series.findAndCountAll({
      where,
      include,
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [[sortBy, order]],
      distinct: true
    });
    
    res.status(200).json({
      count: series.count,
      rows: series.rows,
      totalPages: Math.ceil(series.count / limit)
    });
  } catch (error) {
    console.error('Error fetching series:', error);
    res.status(500).json({ message: "Error fetching series", error: error.message });
  }
};

// Get featured series
const getFeaturedSeries = async (req, res) => {
  try {
    const series = await Series.findAll({
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
    
    res.status(200).json(series);
  } catch (error) {
    console.error('Error fetching featured series:', error);
    res.status(500).json({ message: "Error fetching featured series", error: error.message });
  }
};

// Get a single series by ID with seasons and episodes
const getSeriesById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const series = await Series.findOne({
      where: { id, isActive: true },
      include: [
        { model: Category },
        { model: Genre },
        { 
          model: Season,
          include: [
            { 
              model: Episode,
              where: { isActive: true },
              required: false
            }
          ],
          where: { isActive: true },
          required: false
        },
        { model: Media }
      ]
    });
    
    if (!series) {
      return res.status(404).json({ message: "Series not found" });
    }
    
    // Update view count
    await series.update({ viewCount: series.viewCount + 1 });
    
    res.status(200).json(series);
  } catch (error) {
    console.error('Error fetching series:', error);
    res.status(500).json({ message: "Error fetching series", error: error.message });
  }
};

// Get a single season by ID with episodes
const getSeasonById = async (req, res) => {
  try {
    const { seriesId, seasonId } = req.params;
    
    const season = await Season.findOne({
      where: { 
        id: seasonId,
        seriesId: seriesId,
        isActive: true 
      },
      include: [
        { 
          model: Episode,
          where: { isActive: true },
          required: false,
          order: [['episodeNumber', 'ASC']]
        },
        { model: Media }
      ]
    });
    
    if (!season) {
      return res.status(404).json({ message: "Season not found" });
    }
    
    res.status(200).json(season);
  } catch (error) {
    console.error('Error fetching season:', error);
    res.status(500).json({ message: "Error fetching season", error: error.message });
  }
};

// Get a single episode by ID
const getEpisodeById = async (req, res) => {
  try {
    const { seriesId, seasonId, episodeId } = req.params;
    
    const episode = await Episode.findOne({
      where: { 
        id: episodeId,
        seasonId: seasonId,
        isActive: true 
      },
      include: [
        { model: Media }
      ]
    });
    
    if (!episode) {
      return res.status(404).json({ message: "Episode not found" });
    }
    
    // Update view count
    await episode.update({ viewCount: episode.viewCount + 1 });
    
    res.status(200).json(episode);
  } catch (error) {
    console.error('Error fetching episode:', error);
    res.status(500).json({ message: "Error fetching episode", error: error.message });
  }
};

// Get popular series
const getPopularSeries = async (req, res) => {
  try {
    const { limit = 10 } = req.query;
    
    const series = await Series.findAll({
      where: { isActive: true },
      include: [
        { model: Category },
        { model: Genre },
        { model: Media, where: { type: 'poster', isDefault: true }, required: false }
      ],
      order: [['viewCount', 'DESC']],
      limit: parseInt(limit)
    });
    
    res.status(200).json(series);
  } catch (error) {
    console.error('Error fetching popular series:', error);
    res.status(500).json({ message: "Error fetching popular series", error: error.message });
  }
};

module.exports = {
  getAllSeries,
  getFeaturedSeries,
  getSeriesById,
  getSeasonById,
  getEpisodeById,
  getPopularSeries
};