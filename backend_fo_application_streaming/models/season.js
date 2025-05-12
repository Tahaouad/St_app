'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Season extends Model {
    static associate(models) {
      Season.belongsTo(models.Series, { foreignKey: 'seriesId' });
      Season.hasMany(models.Episode, { foreignKey: 'seasonId' });
      Season.hasMany(models.Rating, { foreignKey: 'seasonId' });
      Season.hasMany(models.WatchHistory, { foreignKey: 'seasonId' });
      Season.hasMany(models.Media, { foreignKey: 'seasonId' });
    }
  }
  
  Season.init({
    seriesId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    seasonNumber: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    title: {
      type: DataTypes.STRING,
      allowNull: false
    },
    description: DataTypes.TEXT,
    releaseDate: DataTypes.DATE,
    posterUrl: DataTypes.STRING,
    trailerUrl: DataTypes.STRING,
    episodeCount: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    sequelize,
    modelName: 'Season',
    timestamps: true
  });
  
  return Season;
};