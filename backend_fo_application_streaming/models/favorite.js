'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Favorite extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      Favorite.belongsTo(models.User, { foreignKey: 'userId' });
      Favorite.belongsTo(models.Movie, { foreignKey: 'movieId' });
      Favorite.belongsTo(models.Series, { foreignKey: 'seriesId' });
          }
  }
  Favorite.init({
    userId: DataTypes.INTEGER,
    movieId: DataTypes.INTEGER,
    seriesId: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'Favorite',
  });
  return Favorite;
};