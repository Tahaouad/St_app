'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Movie extends Model {
    static associate(models) {
      Movie.belongsTo(models.Category, { foreignKey: 'categoryId' });
      Movie.belongsToMany(models.Genre, { through: 'MovieGenres', foreignKey: 'movieId' });
      
      Movie.hasMany(models.Favorite, { foreignKey: 'movieId' });
      Movie.hasMany(models.Rating, { foreignKey: 'movieId' });
      Movie.hasMany(models.WatchHistory, { foreignKey: 'movieId' });
      Movie.hasMany(models.Media, { foreignKey: 'movieId' });
    }
  }
  
  Movie.init({
    title: {
      type: DataTypes.STRING,
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    duration: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    releaseYear: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    director: DataTypes.STRING,
    cast: DataTypes.TEXT,
    ratingAVG: {
      type: DataTypes.FLOAT,
      defaultValue: 0
    },
    posterUrl: DataTypes.STRING,
    backdropUrl: DataTypes.STRING,
    trailerUrl: DataTypes.STRING,
    videoUrl: DataTypes.STRING,
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    categoryId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    isFeatured: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    maturityRating: {
      type: DataTypes.STRING,
      defaultValue: 'PG'
    },
    viewCount: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    }
  }, {
    sequelize,
    modelName: 'Movie',
  });
  
  return Movie;
};