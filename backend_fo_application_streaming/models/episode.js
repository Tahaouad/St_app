'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Episode extends Model {
    static associate(models) {
      Episode.belongsTo(models.Season, { foreignKey: 'seasonId' });
      Episode.hasMany(models.Rating, { foreignKey: 'episodeId' });
      Episode.hasMany(models.WatchHistory, { foreignKey: 'episodeId' });
      Episode.hasMany(models.Media, { foreignKey: 'episodeId' });
    }
  }
  
  Episode.init({
    seasonId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    title: {
      type: DataTypes.STRING,
      allowNull: false
    },
    description: DataTypes.TEXT,
    duration: {
      type: DataTypes.INTEGER, // in minutes
      allowNull: false
    },
    episodeNumber: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    videoUrl: {
      type: DataTypes.STRING,
      allowNull: false
    },
    thumbnailUrl: DataTypes.STRING,
    releaseDate: DataTypes.DATE,
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    viewCount: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    }
  }, {
    sequelize,
    modelName: 'Episode',
    timestamps: true
  });
  
  return Episode;
};
