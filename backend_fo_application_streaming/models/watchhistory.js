'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class WatchHistory extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      WatchHistory.belongsTo(models.User, { foreignKey: 'userId' });
      WatchHistory.belongsTo(models.Movie, { foreignKey: 'movieId' });
      WatchHistory.belongsTo(models.Series, { foreignKey: 'seriesId' });
      WatchHistory.belongsTo(models.Season, { foreignKey: 'seasonId' });
      WatchHistory.belongsTo(models.Episode, { foreignKey: 'episodeId' });
          }
  }
  WatchHistory.init({
    userId: DataTypes.INTEGER,
    movieId: DataTypes.INTEGER,
    seriesId: DataTypes.INTEGER,
    seasonId: DataTypes.INTEGER,
    episodeId: DataTypes.INTEGER,
    watchedAt: DataTypes.DATE,
    progress: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'WatchHistory',
  });
  return WatchHistory;
};