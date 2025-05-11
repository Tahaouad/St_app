'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Series extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      Series.belongsTo(models.Category, { foreignKey: 'categoryId' }); // Si tu veux aussi pour Series
      models.Category.hasMany(Series, { foreignKey: 'categoryId' });
      
      Series.belongsToMany(models.Genre, { through: 'SeriesGenres', foreignKey: 'seriesId' }); // Série a plusieurs genres
      models.Genre.belongsToMany(Series, { through: 'SeriesGenres', foreignKey: 'genreId' });
      
      Series.hasMany(models.Season, { foreignKey: 'seriesId' });
      Series.hasMany(models.Favorite, { foreignKey: 'seriesId' });
      Series.hasMany(models.Rating, { foreignKey: 'seriesId' });
      Series.hasMany(models.WatchHistory, { foreignKey: 'seriesId' });
      Series.hasMany(models.Media, { foreignKey: 'seriesId' });
      
    }
  }
  Series.init({
    title: DataTypes.STRING,
    description: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'Series',
  });
  return Series;
};