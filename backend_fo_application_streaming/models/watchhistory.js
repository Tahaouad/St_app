'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class WatchHistory extends Model {
    static associate(models) {
      WatchHistory.belongsTo(models.User, { foreignKey: 'userId' });
    }
  }
  
  WatchHistory.init({
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    tmdbId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    mediaType: {
      type: DataTypes.ENUM('movie', 'tv', 'episode'),
      allowNull: false
    },
    // Pour les épisodes/séries
    seasonNumber: DataTypes.INTEGER,
    episodeNumber: DataTypes.INTEGER,
    
    title: DataTypes.STRING,
    posterPath: DataTypes.STRING,
    
    watchedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    },
    progress: {
      type: DataTypes.INTEGER, // en secondes
      defaultValue: 0
    },
    duration: DataTypes.INTEGER, // durée totale en secondes
    completed: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    }
  }, {
    sequelize,
    modelName: 'WatchHistory',
    timestamps: true
  });
  
  return WatchHistory;
};