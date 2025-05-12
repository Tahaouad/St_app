const { Favorite, Rating, WatchHistory, Movie, Series, Season, Episode } = require('../models');

// Add content to favorites
const addToFavorites = async (req, res) => {
  try {
    const userId = req.user.id;
    const { movieId, seriesId } = req.body;
    
    if (!movieId && !seriesId) {
      return res.status(400).json({ message: "Either movieId or seriesId is required" });
    }
    
    // Check if the favorite already exists
    const existingFavorite = await Favorite.findOne({
      where: {
        userId,
        ...(movieId ? { movieId } : {}),
        ...(seriesId ? { seriesId } : {})
      }
    });
    
    if (existingFavorite) {
      return res.status(400).json({ message: "Content already in favorites" });
    }
    
    // Create new favorite
    const favorite = await Favorite.create({
      userId,
      ...(movieId ? { movieId } : {}),
      ...(seriesId ? { seriesId } : {})
    });
    
    res.status(201).json({ message: "Added to favorites", favorite });
  } catch (error) {
    console.error('Error adding to favorites:', error);
    res.status(500).json({ message: "Error adding to favorites", error: error.message });
  }
};

// Remove content from favorites
const removeFromFavorites = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;
    
    const favorite = await Favorite.findOne({
      where: { id, userId }
    });
    
    if (!favorite) {
      return res.status(404).json({ message: "Favorite not found" });
    }
    
    await favorite.destroy();
    
    res.status(200).json({ message: "Removed from favorites" });
  } catch (error) {
    console.error('Error removing from favorites:', error);
    res.status(500).json({ message: "Error removing from favorites", error: error.message });
  }
};

// Get user favorites
const getUserFavorites = async (req, res) => {
  try {
    const userId = req.user.id;
    
    const favorites = await Favorite.findAll({
      where: { userId },
      include: [
        { model: Movie },
        { model: Series }
      ]
    });
    
    res.status(200).json(favorites);
  } catch (error) {
    console.error('Error fetching favorites:', error);
    res.status(500).json({ message: "Error fetching favorites", error: error.message });
  }
};

// Add or update rating
const addRating = async (req, res) => {
  try {
    const userId = req.user.id;
    const { movieId, seriesId, seasonId, episodeId, rating, comment } = req.body;
    
    if (!movieId && !seriesId && !seasonId && !episodeId) {
      return res.status(400).json({ message: "One of movieId, seriesId, seasonId, or episodeId is required" });
    }
    
    if (!rating || rating < 1 || rating > 10) {
      return res.status(400).json({ message: "Rating must be between 1 and 10" });
    }
    
    // Check if rating already exists
    const existingRating = await Rating.findOne({
      where: {
        userId,
        ...(movieId ? { movieId } : {}),
        ...(seriesId ? { seriesId } : {}),
        ...(seasonId ? { seasonId } : {}),
        ...(episodeId ? { episodeId } : {})
      }
    });
    
    if (existingRating) {
      // Update existing rating
      await existingRating.update({ rating, comment });
      res.status(200).json({ message: "Rating updated", rating: existingRating });
    } else {
      // Create new rating
      const newRating = await Rating.create({
        userId,
        rating,
        comment,
        ...(movieId ? { movieId } : {}),
        ...(seriesId ? { seriesId } : {}),
        ...(seasonId ? { seasonId } : {}),
        ...(episodeId ? { episodeId } : {})
      });
      
      res.status(201).json({ message: "Rating added", rating: newRating });
    }
  } catch (error) {
    console.error('Error adding rating:', error);
    res.status(500).json({ message: "Error adding rating", error: error.message });
  }
};

// Update watch history
const updateWatchHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const { movieId, seriesId, seasonId, episodeId, progress, completed } = req.body;
    
    if (!movieId && !episodeId) {
      return res.status(400).json({ message: "Either movieId or episodeId is required" });
    }
    
    // Find or create watch history
    let watchHistory = await WatchHistory.findOne({
      where: {
        userId,
        ...(movieId ? { movieId } : {}),
        ...(seriesId ? { seriesId } : {}),
        ...(seasonId ? { seasonId } : {}),
        ...(episodeId ? { episodeId } : {})
      }
    });
    
    if (watchHistory) {
      // Update existing watch history
      await watchHistory.update({
        progress,
        completed: completed || false,
        watchedAt: new Date()
      });
    } else {
      // Create new watch history
      watchHistory = await WatchHistory.create({
        userId,
        progress,
        completed: completed || false,
        ...(movieId ? { movieId } : {}),
        ...(seriesId ? { seriesId } : {}),
        ...(seasonId ? { seasonId } : {}),
        ...(episodeId ? { episodeId } : {})
      });
    }
    
    res.status(200).json({ message: "Watch history updated", watchHistory });
  } catch (error) {
    console.error('Error updating watch history:', error);
    res.status(500).json({ message: "Error updating watch history", error: error.message });
  }
};

// Get user watch history
const getWatchHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    
    const watchHistory = await WatchHistory.findAll({
      where: { userId },
      include: [
        { model: Movie },
        { model: Series },
        { model: Season },
        { model: Episode }
      ],
      order: [['watchedAt', 'DESC']],
      limit: 20
    });
    
    res.status(200).json(watchHistory);
  } catch (error) {
    console.error('Error fetching watch history:', error);
    res.status(500).json({ message: "Error fetching watch history", error: error.message });
  }
};

module.exports = {
  addToFavorites,
  removeFromFavorites,
  getUserFavorites,
  addRating,
  updateWatchHistory,
  getWatchHistory
};