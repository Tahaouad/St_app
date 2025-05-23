'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Rating extends Model {
    static associate(models) {
      Rating.belongsTo(models.User, { foreignKey: 'userId' });
    }
  }
  
  Rating.init({
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
    // Pour les épisodes
    seasonNumber: DataTypes.INTEGER,
    episodeNumber: DataTypes.INTEGER,
    
    rating: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 1,
        max: 10
      }
    },
    comment: DataTypes.TEXT,
    title: DataTypes.STRING 
  }, {
    sequelize,
    modelName: 'Rating',
    timestamps: true
  });
  
  return Rating;
};