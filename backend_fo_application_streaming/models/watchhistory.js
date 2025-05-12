'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class WatchHistory extends Model {
    static associate(models) {
      WatchHistory.belongsTo(models.User, { foreignKey: 'userId' });
      WatchHistory.belongsTo(models.Movie, { foreignKey: 'movieId' });
      WatchHistory.belongsTo(models.Series, { foreignKey: 'seriesId' });
      WatchHistory.belongsTo(models.Season, { foreignKey: 'seasonId' });
      WatchHistory.belongsTo(models.Episode, { foreignKey: 'episodeId' });
    }
  }
  
  WatchHistory.init({
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    movieId: DataTypes.INTEGER,
    seriesId: DataTypes.INTEGER,
    seasonId: DataTypes.INTEGER,
    episodeId: DataTypes.INTEGER,
    watchedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    },
    progress: {
      type: DataTypes.INTEGER, // in seconds
      defaultValue: 0
    },
    completed: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    watchDuration: {
      type: DataTypes.INTEGER, // in seconds
      defaultValue: 0
    }
  }, {
    sequelize,
    modelName: 'WatchHistory',
    timestamps: true
  });
  
  return WatchHistory;
};