'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Series extends Model {
    static associate(models) {
      Series.belongsTo(models.Category, { foreignKey: 'categoryId' });
      Series.belongsToMany(models.Genre, { through: 'SeriesGenres', foreignKey: 'seriesId' });
      
      Series.hasMany(models.Season, { foreignKey: 'seriesId' });
      Series.hasMany(models.Favorite, { foreignKey: 'seriesId' });
      Series.hasMany(models.Rating, { foreignKey: 'seriesId' });
      Series.hasMany(models.WatchHistory, { foreignKey: 'seriesId' });
      Series.hasMany(models.Media, { foreignKey: 'seriesId' });
    }
  }
  
  Series.init({
    title: {
      type: DataTypes.STRING,
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    releaseYear: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    endYear: DataTypes.INTEGER,
    creator: DataTypes.STRING,
    cast: DataTypes.TEXT,
    ratingAVG: {
      type: DataTypes.FLOAT,
      defaultValue: 0
    },
    posterUrl: DataTypes.STRING,
    backdropUrl: DataTypes.STRING,
    trailerUrl: DataTypes.STRING,
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
    status: {
      type: DataTypes.ENUM('ongoing', 'completed', 'cancelled'),
      defaultValue: 'ongoing'
    },
    viewCount: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    }
  }, {
    sequelize,
    modelName: 'Series',
    timestamps: true
  });
  
  return Series;
};