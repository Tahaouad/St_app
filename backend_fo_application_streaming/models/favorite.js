'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Favorite extends Model {
    static associate(models) {
      Favorite.belongsTo(models.User, { foreignKey: 'userId' });
      Favorite.belongsTo(models.Movie, { foreignKey: 'movieId' });
      Favorite.belongsTo(models.Series, { foreignKey: 'seriesId' });
    }
  }
  
  Favorite.init({
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    movieId: DataTypes.INTEGER,
    seriesId: DataTypes.INTEGER,
    addedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    sequelize,
    modelName: 'Favorite',
    timestamps: true
  });
  
  return Favorite;
};