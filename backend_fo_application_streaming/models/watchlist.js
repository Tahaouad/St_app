'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Watchlist extends Model {
    static associate(models) {
      Watchlist.belongsTo(models.User, { foreignKey: 'userId' });
    }
  }
  
  Watchlist.init({
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    tmdbId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    mediaType: {
      type: DataTypes.ENUM('movie', 'tv'),
      allowNull: false
    },
    title: {
      type: DataTypes.STRING,
      allowNull: false
    },
    posterPath: DataTypes.STRING,
    addedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    sequelize,
    modelName: 'Watchlist',
    timestamps: true
  });
  
  return Watchlist;
};