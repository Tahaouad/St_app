'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Category extends Model {
    static associate(models) {
      Category.hasMany(models.Movie, { foreignKey: 'categoryId' });
      Category.hasMany(models.Series, { foreignKey: 'categoryId' });
    }
  }
  
  Category.init({
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    description: DataTypes.STRING,
    imageUrl: DataTypes.STRING,
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    displayOrder: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    }
  }, {
    sequelize,
    modelName: 'Category',
    timestamps: true
  });
  
  return Category;
};