'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Media extends Model {
    static associate(models) {
      Media.belongsTo(models.Movie, { foreignKey: 'movieId' });
      Media.belongsTo(models.Series, { foreignKey: 'seriesId' });
      Media.belongsTo(models.Season, { foreignKey: 'seasonId' });
      Media.belongsTo(models.Episode, { foreignKey: 'episodeId' });
    }
  }
  
  Media.init({
    url: {
      type: DataTypes.STRING,
      allowNull: false
    },
    type: {
      type: DataTypes.ENUM('poster', 'backdrop', 'thumbnail', 'video', 'trailer', 'other'),
      allowNull: false
    },
    title: DataTypes.STRING,
    description: DataTypes.TEXT,
    movieId: DataTypes.INTEGER,
    seriesId: DataTypes.INTEGER,
    seasonId: DataTypes.INTEGER,
    episodeId: DataTypes.INTEGER,
    isDefault: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    }
  }, {
    sequelize,
    modelName: 'Media',
    timestamps: true
  });
  
  return Media;
};