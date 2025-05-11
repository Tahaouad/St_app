'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Episode extends Model {
    static associate(models) {
      // Associate Episode with Season, Rating, WatchHistory, and Media
      Episode.belongsTo(models.Season, { foreignKey: 'seasonId' });
      models.Season.hasMany(Episode, { foreignKey: 'seasonId' });

      Episode.hasMany(models.Rating, { foreignKey: 'episodeId' });
      Episode.hasMany(models.WatchHistory, { foreignKey: 'episodeId' });
      Episode.hasMany(models.Media, { foreignKey: 'episodeId' });
    }
  }

  Episode.init({
    seasonId: DataTypes.INTEGER,
    title: DataTypes.STRING,
    description: DataTypes.STRING,
    duration: DataTypes.INTEGER,
    episodeNumber: DataTypes.INTEGER,
    videoUrl: DataTypes.STRING,
    releaseDate: DataTypes.DATE
  }, {
    sequelize,
    modelName: 'Episode',
  });

  return Episode;
};
