'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Media extends Model {
    static associate(models) {
      Media.belongsTo(models.Movie, { foreignKey: 'movieId' });
      Media.belongsTo(models.Series, { foreignKey: 'seriesId' });
      Media.belongsTo(models.Season, { foreignKey: 'seasonId' });
      Media.belongsTo(models.Episode, { foreignKey: 'episodeId' });
          }
  }
  Media.init({
    url: DataTypes.STRING,
    type: DataTypes.STRING,
    movieId: DataTypes.INTEGER,
    seriesId: DataTypes.INTEGER,
    seasonId: DataTypes.INTEGER,
    episodeId: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'Media',
  });
  return Media;
};