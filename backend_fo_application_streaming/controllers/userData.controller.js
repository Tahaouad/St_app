// controllers/userData.controller.js
const { Watchlist, Rating, WatchHistory } = require('../models');
const tmdbService = require('../services/tmdbService');
const { Op } = require('sequelize');

// ===============================
// === WATCHLIST MANAGEMENT ===
// ===============================

const addToWatchlist = async (req, res) => {
  try {
    const userId = req.user.id;
    const { tmdbId, mediaType, title, posterPath } = req.body;
    
    // Validation des données requises
    if (!tmdbId || !mediaType || !title) {
      return res.status(400).json({ 
        message: "tmdbId, mediaType et title sont requis",
        required: ["tmdbId", "mediaType", "title"]
      });
    }
    
    // Validation du type de média
    if (!['movie', 'tv'].includes(mediaType)) {
      return res.status(400).json({ 
        message: "mediaType doit être 'movie' ou 'tv'" 
      });
    }
    
    // Vérifier si déjà en watchlist
    const existing = await Watchlist.findOne({
      where: { 
        userId, 
        tmdbId: parseInt(tmdbId), 
        mediaType 
      }
    });
    
    if (existing) {
      return res.status(409).json({ 
        message: "Ce contenu est déjà dans votre watchlist",
        item: existing
      });
    }
    
    // Créer l'entrée watchlist
    const watchlistItem = await Watchlist.create({
      userId,
      tmdbId: parseInt(tmdbId),
      mediaType,
      title,
      posterPath
    });
    
    res.status(201).json({ 
      message: "Ajouté à la watchlist avec succès", 
      item: {
        ...watchlistItem.toJSON(),
        poster_url: tmdbService.getImageUrl(watchlistItem.posterPath)
      }
    });
    
  } catch (error) {
    console.error('Erreur ajout watchlist:', error);
    
    // Gestion des erreurs de contrainte unique
    if (error.name === 'SequelizeUniqueConstraintError') {
      return res.status(409).json({ 
        message: "Ce contenu est déjà dans votre watchlist" 
      });
    }
    
    res.status(500).json({ 
      message: "Erreur lors de l'ajout à la watchlist", 
      error: error.message 
    });
  }
};

const removeFromWatchlist = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;
    
    if (!id || isNaN(parseInt(id))) {
      return res.status(400).json({ message: "ID invalide" });
    }
    
    const item = await Watchlist.findOne({
      where: { 
        id: parseInt(id), 
        userId 
      }
    });
    
    if (!item) {
      return res.status(404).json({ 
        message: "Élément non trouvé dans votre watchlist" 
      });
    }
    
    await item.destroy();
    
    res.json({ 
      message: "Retiré de la watchlist avec succès",
      removedItem: {
        id: item.id,
        title: item.title,
        mediaType: item.mediaType
      }
    });
    
  } catch (error) {
    console.error('Erreur suppression watchlist:', error);
    res.status(500).json({ 
      message: "Erreur lors de la suppression", 
      error: error.message 
    });
  }
};

const getWatchlist = async (req, res) => {
  try {
    const userId = req.user.id;
    const { 
      page = 1, 
      limit = 20, 
      mediaType,
      sortBy = 'addedAt',
      order = 'DESC'
    } = req.query;
    
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const whereClause = { userId };
    
    // Filtrer par type de média si spécifié
    if (mediaType && ['movie', 'tv'].includes(mediaType)) {
      whereClause.mediaType = mediaType;
    }
    
    // Validation des options de tri
    const validSortFields = ['addedAt', 'title', 'mediaType'];
    const validOrder = ['ASC', 'DESC'];
    
    const orderBy = validSortFields.includes(sortBy) ? sortBy : 'addedAt';
    const orderDirection = validOrder.includes(order.toUpperCase()) ? order.toUpperCase() : 'DESC';
    
    const { count, rows } = await Watchlist.findAndCountAll({
      where: whereClause,
      order: [[orderBy, orderDirection]],
      limit: parseInt(limit),
      offset: offset
    });
    
    // Enrichir avec les URLs d'images complètes
    const enrichedItems = rows.map(item => ({
      ...item.toJSON(),
      poster_url: tmdbService.getImageUrl(item.posterPath),
      added_days_ago: Math.floor((new Date() - new Date(item.addedAt)) / (1000 * 60 * 60 * 24))
    }));
    
    res.json({
      items: enrichedItems,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(count / parseInt(limit)),
        hasNext: parseInt(page) < Math.ceil(count / parseInt(limit)),
        hasPrev: parseInt(page) > 1
      },
      stats: {
        totalMovies: await Watchlist.count({ where: { userId, mediaType: 'movie' } }),
        totalTV: await Watchlist.count({ where: { userId, mediaType: 'tv' } })
      }
    });
    
  } catch (error) {
    console.error('Erreur récupération watchlist:', error);
    res.status(500).json({ 
      message: "Erreur lors de la récupération de la watchlist", 
      error: error.message 
    });
  }
};

const checkInWatchlist = async (req, res) => {
  try {
    const userId = req.user.id;
    const { tmdbId, mediaType } = req.query;
    
    if (!tmdbId || !mediaType) {
      return res.status(400).json({ 
        message: "tmdbId et mediaType sont requis" 
      });
    }
    
    if (!['movie', 'tv'].includes(mediaType)) {
      return res.status(400).json({ 
        message: "mediaType doit être 'movie' ou 'tv'" 
      });
    }
    
    const exists = await Watchlist.findOne({
      where: { 
        userId, 
        tmdbId: parseInt(tmdbId), 
        mediaType 
      }
    });
    
    res.json({ 
      inWatchlist: !!exists,
      item: exists ? {
        id: exists.id,
        addedAt: exists.addedAt
      } : null
    });
    
  } catch (error) {
    console.error('Erreur vérification watchlist:', error);
    res.status(500).json({ 
      message: "Erreur lors de la vérification", 
      error: error.message 
    });
  }
};

// ===============================
// === RATINGS MANAGEMENT ===
// ===============================

const addRating = async (req, res) => {
  try {
    const userId = req.user.id;
    const { 
      tmdbId, 
      mediaType, 
      rating, 
      comment, 
      title,
      seasonNumber = null,
      episodeNumber = null 
    } = req.body;
    
    // Validation des données requises
    if (!tmdbId || !mediaType || !rating || !title) {
      return res.status(400).json({ 
        message: "tmdbId, mediaType, rating et title sont requis",
        required: ["tmdbId", "mediaType", "rating", "title"]
      });
    }
    
    // Validation du type de média
    if (!['movie', 'tv', 'episode'].includes(mediaType)) {
      return res.status(400).json({ 
        message: "mediaType doit être 'movie', 'tv' ou 'episode'" 
      });
    }
    
    // Validation de la note
    const ratingValue = parseInt(rating);
    if (isNaN(ratingValue) || ratingValue < 1 || ratingValue > 10) {
      return res.status(400).json({ 
        message: "La note doit être un nombre entier entre 1 et 10" 
      });
    }
    
    // Pour les épisodes, vérifier que season et episode sont fournis
    if (mediaType === 'episode' && (!seasonNumber || !episodeNumber)) {
      return res.status(400).json({
        message: "seasonNumber et episodeNumber sont requis pour les épisodes"
      });
    }
    
    // Construire la clause WHERE pour upsert
    const whereClause = {
      userId,
      tmdbId: parseInt(tmdbId),
      mediaType
    };
    
    if (seasonNumber !== null) whereClause.seasonNumber = parseInt(seasonNumber);
    if (episodeNumber !== null) whereClause.episodeNumber = parseInt(episodeNumber);
    
    // Créer ou mettre à jour la note
    const [ratingRecord, created] = await Rating.upsert({
      ...whereClause,
      rating: ratingValue,
      comment: comment || null,
      title
    });
    
    res.status(created ? 201 : 200).json({
      message: created ? "Note ajoutée avec succès" : "Note mise à jour avec succès",
      rating: ratingRecord,
      action: created ? 'created' : 'updated'
    });
    
  } catch (error) {
    console.error('Erreur ajout rating:', error);
    res.status(500).json({ 
      message: "Erreur lors de l'ajout de la note", 
      error: error.message 
    });
  }
};

const getUserRatings = async (req, res) => {
  try {
    const userId = req.user.id;
    const { 
      page = 1, 
      limit = 20, 
      mediaType,
      minRating,
      maxRating,
      sortBy = 'updatedAt',
      order = 'DESC'
    } = req.query;
    
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const whereClause = { userId };
    
    // Filtres
    if (mediaType && ['movie', 'tv', 'episode'].includes(mediaType)) {
      whereClause.mediaType = mediaType;
    }
    
    if (minRating && !isNaN(parseInt(minRating))) {
      whereClause.rating = { [Op.gte]: parseInt(minRating) };
    }
    
    if (maxRating && !isNaN(parseInt(maxRating))) {
      whereClause.rating = {
        ...whereClause.rating,
        [Op.lte]: parseInt(maxRating)
      };
    }
    
    // Validation des options de tri  
    const validSortFields = ['updatedAt', 'rating', 'title', 'mediaType'];
    const validOrder = ['ASC', 'DESC'];
    
    const orderBy = validSortFields.includes(sortBy) ? sortBy : 'updatedAt';
    const orderDirection = validOrder.includes(order.toUpperCase()) ? order.toUpperCase() : 'DESC';
    
    const { count, rows } = await Rating.findAndCountAll({
      where: whereClause,
      order: [[orderBy, orderDirection]],
      limit: parseInt(limit),
      offset: offset
    });
    
    res.json({
      ratings: rows,
      pagination: {
        total: count,
        page: parseInt(page), 
        limit: parseInt(limit),
        totalPages: Math.ceil(count / parseInt(limit)),
        hasNext: parseInt(page) < Math.ceil(count / parseInt(limit)),
        hasPrev: parseInt(page) > 1
      },
      stats: {
        averageRating: await Rating.findOne({
          where: { userId },
          attributes: [[require('sequelize').fn('AVG', require('sequelize').col('rating')), 'avg']],
          raw: true
        }).then(result => parseFloat(result?.avg || 0).toFixed(1)),
        totalRatings: count,
        ratingDistribution: await Rating.findAll({
          where: { userId },
          attributes: [
            'rating',
            [require('sequelize').fn('COUNT', require('sequelize').col('rating')), 'count']
          ],
          group: ['rating'],
          order: [['rating', 'ASC']],
          raw: true
        })
      }
    });
    
  } catch (error) {
    console.error('Erreur récupération ratings:', error);
    res.status(500).json({ 
      message: "Erreur lors de la récupération des notes", 
      error: error.message 
    });
  }
};

const getUserRating = async (req, res) => {
  try {
    const userId = req.user.id;
    const { tmdbId, mediaType, seasonNumber, episodeNumber } = req.query;
    
    if (!tmdbId || !mediaType) {
      return res.status(400).json({ 
        message: "tmdbId et mediaType sont requis" 
      });
    }
    
    const whereClause = {
      userId,
      tmdbId: parseInt(tmdbId),
      mediaType
    };
    
    if (seasonNumber) whereClause.seasonNumber = parseInt(seasonNumber);
    if (episodeNumber) whereClause.episodeNumber = parseInt(episodeNumber);
    
    const rating = await Rating.findOne({ where: whereClause });
    
    res.json({ 
      rating,
      hasRating: !!rating
    });
    
  } catch (error) {
    console.error('Erreur récupération rating:', error);
    res.status(500).json({ 
      message: "Erreur lors de la récupération de la note", 
      error: error.message 
    });
  }
};

const deleteRating = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;
    
    if (!id || isNaN(parseInt(id))) {
      return res.status(400).json({ message: "ID invalide" });
    }
    
    const rating = await Rating.findOne({
      where: { 
        id: parseInt(id), 
        userId 
      }
    });
    
    if (!rating) {
      return res.status(404).json({ 
        message: "Note non trouvée" 
      });
    }
    
    await rating.destroy();
    
    res.json({ 
      message: "Note supprimée avec succès",
      deletedRating: {
        id: rating.id,
        title: rating.title,
        rating: rating.rating
      }
    });
    
  } catch (error) {
    console.error('Erreur suppression rating:', error);
    res.status(500).json({ 
      message: "Erreur lors de la suppression de la note", 
      error: error.message 
    });
  }
};

// ===============================
// === WATCH HISTORY MANAGEMENT ===
// ===============================

const updateWatchHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const {
      tmdbId,
      mediaType,
      title,
      posterPath,
      progress = 0,
      duration,
      completed = false,
      seasonNumber = null,
      episodeNumber = null
    } = req.body;
    
    // Validation des données requises
    if (!tmdbId || !mediaType || !title) {
      return res.status(400).json({ 
        message: "tmdbId, mediaType et title sont requis",
        required: ["tmdbId", "mediaType", "title"]
      });
    }
    
    // Validation du type de média
    if (!['movie', 'tv', 'episode'].includes(mediaType)) {
      return res.status(400).json({ 
        message: "mediaType doit être 'movie', 'tv' ou 'episode'" 
      });
    }
    
    // Validation des valeurs numériques
    const progressValue = parseInt(progress) || 0;
    const durationValue = duration ? parseInt(duration) : null;
    
    if (progressValue < 0) {
      return res.status(400).json({ 
        message: "Le progrès ne peut pas être négatif" 
      });
    }
    
    if (durationValue && durationValue <= 0) {
      return res.status(400).json({ 
        message: "La durée doit être positive" 
      });
    }
    
    // Construire la clause WHERE
    const whereClause = {
      userId,
      tmdbId: parseInt(tmdbId),
      mediaType
    };
    
    if (seasonNumber !== null) whereClause.seasonNumber = parseInt(seasonNumber);
    if (episodeNumber !== null) whereClause.episodeNumber = parseInt(episodeNumber);
    
    // Créer ou mettre à jour l'historique
    const [watchHistory, created] = await WatchHistory.upsert({
      ...whereClause,
      title,
      posterPath,
      progress: progressValue,
      duration: durationValue,
      completed: !!completed,
      watchedAt: new Date()
    });
    
    const enrichedHistory = {
      ...watchHistory.toJSON(),
      poster_url: tmdbService.getImageUrl(watchHistory.posterPath),
      progressPercentage: watchHistory.duration ? 
        Math.round((watchHistory.progress / watchHistory.duration) * 100) : 0
    };
    
    res.json({
      message: created ? "Historique créé avec succès" : "Historique mis à jour avec succès",
      watchHistory: enrichedHistory,
      action: created ? 'created' : 'updated'
    });
    
  } catch (error) {
    console.error('Erreur mise à jour historique:', error);
    res.status(500).json({ 
      message: "Erreur lors de la mise à jour de l'historique", 
      error: error.message 
    });
  }
};

const getWatchHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const { 
      page = 1, 
      limit = 20, 
      mediaType,
      completed,
      sortBy = 'watchedAt',
      order = 'DESC'
    } = req.query;
    
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const whereClause = { userId };
    
    // Filtres
    if (mediaType && ['movie', 'tv', 'episode'].includes(mediaType)) {
      whereClause.mediaType = mediaType;
    }
    
    if (completed !== undefined) {
      whereClause.completed = completed === 'true';
    }
    
    // Validation des options de tri
    const validSortFields = ['watchedAt', 'title', 'progress', 'mediaType'];
    const validOrder = ['ASC', 'DESC'];
    
    const orderBy = validSortFields.includes(sortBy) ? sortBy : 'watchedAt';
    const orderDirection = validOrder.includes(order.toUpperCase()) ? order.toUpperCase() : 'DESC';
    
    const { count, rows } = await WatchHistory.findAndCountAll({
      where: whereClause,
      order: [[orderBy, orderDirection]],
      limit: parseInt(limit),
      offset: offset
    });
    
    // Enrichir avec les URLs d'images et calculs
    const enrichedHistory = rows.map(item => ({
      ...item.toJSON(),
      poster_url: tmdbService.getImageUrl(item.posterPath),
      progressPercentage: item.duration ? 
        Math.round((item.progress / item.duration) * 100) : 0,
      watched_days_ago: Math.floor((new Date() - new Date(item.watchedAt)) / (1000 * 60 * 60 * 24)),
      remaining_time: item.duration && !item.completed ? 
        item.duration - item.progress : 0
    }));
    
    res.json({
      history: enrichedHistory,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(count / parseInt(limit)),
        hasNext: parseInt(page) < Math.ceil(count / parseInt(limit)),
        hasPrev: parseInt(page) > 1
      },
      stats: {
        totalWatched: count,
        completedCount: await WatchHistory.count({ where: { userId, completed: true } }),
        inProgressCount: await WatchHistory.count({ 
          where: { 
            userId, 
            completed: false, 
            progress: { [Op.gt]: 0 } 
          } 
        }),
        totalWatchTime: await WatchHistory.sum('progress', { where: { userId } }) || 0
      }
    });
    
  } catch (error) {
    console.error('Erreur récupération historique:', error);
    res.status(500).json({ 
      message: "Erreur lors de la récupération de l'historique", 
      error: error.message 
    });
  }
};

const getWatchProgress = async (req, res) => {
  try {
    const userId = req.user.id;
    const { tmdbId, mediaType, seasonNumber, episodeNumber } = req.query;
    
    if (!tmdbId || !mediaType) {
      return res.status(400).json({ 
        message: "tmdbId et mediaType sont requis" 
      });
    }
    
    const whereClause = {
      userId,
      tmdbId: parseInt(tmdbId),
      mediaType
    };
    
    if (seasonNumber) whereClause.seasonNumber = parseInt(seasonNumber);
    if (episodeNumber) whereClause.episodeNumber = parseInt(episodeNumber);
    
    const watchHistory = await WatchHistory.findOne({ where: whereClause });
    
    const progress = watchHistory ? {
      progress: watchHistory.progress,
      duration: watchHistory.duration,
      completed: watchHistory.completed,
      progressPercentage: watchHistory.duration ? 
        Math.round((watchHistory.progress / watchHistory.duration) * 100) : 0,
      lastWatchedAt: watchHistory.watchedAt,
      remainingTime: watchHistory.duration && !watchHistory.completed ? 
        watchHistory.duration - watchHistory.progress : 0
    } : null;
    
    res.json({ 
      progress,
      hasProgress: !!watchHistory
    });
    
  } catch (error) {
    console.error('Erreur récupération progrès:', error);
    res.status(500).json({ 
      message: "Erreur lors de la récupération du progrès", 
      error: error.message 
    });
  }
};

const getContinueWatching = async (req, res) => {
  try {
    const userId = req.user.id;
    const { limit = 10 } = req.query;
    
    const continueWatching = await WatchHistory.findAll({
      where: {
        userId,
        completed: false,
        progress: { [Op.gt]: 0 }
      },
      order: [['watchedAt', 'DESC']],
      limit: parseInt(limit)
    });
    
    // Enrichir avec les URLs d'images et calculs
    const enrichedItems = continueWatching.map(item => ({
      ...item.toJSON(),
      poster_url: tmdbService.getImageUrl(item.posterPath),
      progressPercentage: item.duration ? 
        Math.round((item.progress / item.duration) * 100) : 0,
      remainingTime: item.duration ? item.duration - item.progress : 0,
      lastWatchedDays: Math.floor((new Date() - new Date(item.watchedAt)) / (1000 * 60 * 60 * 24))
    }));
    
    res.json({ 
      items: enrichedItems,
      count: enrichedItems.length
    });
    
  } catch (error) {
    console.error('Erreur continue watching:', error);
    res.status(500).json({ 
      message: "Erreur lors de la récupération du contenu à continuer", 
      error: error.message 
    });
  }
};

const clearWatchHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const { mediaType, beforeDate } = req.body;
    
    const whereClause = { userId };
    
    if (mediaType && ['movie', 'tv', 'episode'].includes(mediaType)) {
      whereClause.mediaType = mediaType;
    }
    
    if (beforeDate) {
      whereClause.watchedAt = { [Op.lt]: new Date(beforeDate) };
    }
    
    const deletedCount = await WatchHistory.destroy({ where: whereClause });
    
    res.json({
      message: `${deletedCount} entrée(s) supprimée(s) de l'historique`,
      deletedCount
    });
    
  } catch (error) {
    console.error('Erreur nettoyage historique:', error);
    res.status(500).json({ 
      message: "Erreur lors du nettoyage de l'historique", 
      error: error.message 
    });
  }
};

// ===============================
// === USER STATISTICS ===
// ===============================

const getUserStats = async (req, res) => {
  try {
    const userId = req.user.id;
    
    // Statistiques générales
    const [
      watchlistCount,
      ratingsCount,
      watchHistoryCount,
      totalWatchTime,
      averageRating
    ] = await Promise.all([
      Watchlist.count({ where: { userId } }),
      Rating.count({ where: { userId } }),
      WatchHistory.count({ where: { userId } }),
      WatchHistory.sum('progress', { where: { userId } }) || 0,
      Rating.findOne({
        where: { userId },
        attributes: [[require('sequelize').fn('AVG', require('sequelize').col('rating')), 'avg']],
        raw: true
      })
    ]);
    
    // Répartition par type de contenu
    const contentTypeStats = await Promise.all([
      Watchlist.findAll({
        where: { userId },
        attributes: [
          'mediaType',
          [require('sequelize').fn('COUNT', require('sequelize').col('mediaType')), 'count']
        ],
        group: ['mediaType'],
        raw: true
      }),
      WatchHistory.findAll({
        where: { userId },
        attributes: [
          'mediaType',
          [require('sequelize').fn('COUNT', require('sequelize').col('mediaType')), 'count'],
          [require('sequelize').fn('SUM', require('sequelize').col('progress')), 'totalTime']
        ],
        group: ['mediaType'],
        raw: true
      })
    ]);
    
    res.json({
      general: {
        watchlistItems: watchlistCount,
        ratingsGiven: ratingsCount,
        itemsWatched: watchHistoryCount,
        totalWatchTimeSeconds: totalWatchTime,
        totalWatchTimeHours: Math.round(totalWatchTime / 3600),
        averageRating: parseFloat(averageRating?.avg || 0).toFixed(1)
      },
      watchlist: contentTypeStats[0].reduce((acc, item) => {
        acc[item.mediaType] = item.count;
        return acc;
      }, {}),
      watchHistory: contentTypeStats[1].reduce((acc, item) => {
        acc[item.mediaType] = {
          count: item.count,
          totalTime: item.totalTime || 0
        };
        return acc;
      }, {}),
      recentActivity: {
        lastWatchlistAddition: await Watchlist.findOne({
          where: { userId },
          order: [['addedAt', 'DESC']],
          attributes: ['title', 'mediaType', 'addedAt']
        }),
        lastWatched: await WatchHistory.findOne({
          where: { userId },
          order: [['watchedAt', 'DESC']],
          attributes: ['title', 'mediaType', 'watchedAt']
        }),
        lastRating: await Rating.findOne({
          where: { userId },
          order: [['updatedAt', 'DESC']],
          attributes: ['title', 'rating', 'updatedAt']
        })
      }
    });
    
  } catch (error) {
    console.error('Erreur statistiques utilisateur:', error);
    res.status(500).json({ 
      message: "Erreur lors de la récupération des statistiques", 
      error: error.message 
    });
  }
};

// ===============================
// === EXPORTS ===
// ===============================

module.exports = {
  // Watchlist
  addToWatchlist,
  removeFromWatchlist,
  getWatchlist,
  checkInWatchlist,
  
  // Ratings
  addRating,
  getUserRatings,
  getUserRating,
  deleteRating,
  
  // Watch History
  updateWatchHistory,
  getWatchHistory,
  getWatchProgress,
  getContinueWatching,
  clearWatchHistory,
  
  // Statistics
  getUserStats
};