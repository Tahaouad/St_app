'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Rating extends Model {
    static associate(models) {
      Rating.belongsTo(models.User, { foreignKey: 'userId' });
      Rating.belongsTo(models.Movie, { foreignKey: 'movieId' });
      Rating.belongsTo(models.Series, { foreignKey: 'seriesId' });
      Rating.belongsTo(models.Season, { foreignKey: 'seasonId' });
      Rating.belongsTo(models.Episode, { foreignKey: 'episodeId' });
          }
  }
  Rating.init({
    userId: DataTypes.INTEGER,
    movieId: DataTypes.INTEGER,
    seriesId: DataTypes.INTEGER,
    seasonId: DataTypes.INTEGER,
    episodeId: DataTypes.INTEGER,
    rating: DataTypes.INTEGER,
    comment: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'Rating',
  });
  return Rating;
};