'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Genre extends Model {
    static associate(models) {
      Genre.belongsToMany(models.Movie, { through: 'MovieGenres', foreignKey: 'genreId' });
      Genre.belongsToMany(models.Series, { through: 'SeriesGenres', foreignKey: 'genreId' });
    }
  }
  
  Genre.init({
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    description: DataTypes.STRING,
    imageUrl: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'Genre',
    timestamps: true
  });
  
  return Genre;
};