'use strict';
const { Model } = require('sequelize');

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
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    movieId: DataTypes.INTEGER,
    seriesId: DataTypes.INTEGER,
    seasonId: DataTypes.INTEGER,
    episodeId: DataTypes.INTEGER,
    rating: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 1,
        max: 10
      }
    },
    comment: DataTypes.TEXT,
    isRecommended: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    sequelize,
    modelName: 'Rating',
    timestamps: true
  });
  
  return Rating;
};