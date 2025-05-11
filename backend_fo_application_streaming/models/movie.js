'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Movie extends Model {
   
    static associate(models) {
      Movie.belongsTo(models.Category, { foreignKey: 'categoryId' }); // Un film appartient à une catégorie
      models.Category.hasMany(Movie, { foreignKey: 'categoryId' }); // Une catégorie a plusieurs films

      Movie.belongsToMany(models.Genre, { through: 'MovieGenres', foreignKey: 'movieId' }); // Film a plusieurs genres
      models.Genre.belongsToMany(Movie, { through: 'MovieGenres', foreignKey: 'genreId' });

      Movie.hasMany(models.Favorite, { foreignKey: 'movieId' });
      Movie.hasMany(models.Rating, { foreignKey: 'movieId' });
      Movie.hasMany(models.WatchHistory, { foreignKey: 'movieId' });
      Movie.hasMany(models.Media, { foreignKey: 'movieId' });

    }
  }
  Movie.init({
    title: DataTypes.STRING,
    description: DataTypes.STRING,
    duration: DataTypes.INTEGER,
    releaseYear: DataTypes.INTEGER,
    generalId: DataTypes.INTEGER,
    director: DataTypes.STRING,
    cast: DataTypes.STRING,
    ratingAVG: DataTypes.FLOAT,
    posterUrl: DataTypes.STRING,
    trailerUrl: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'Movie',
  });
  return Movie;
};