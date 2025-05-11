'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Season extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      Season.belongsTo(models.Series, { foreignKey: 'seriesId' });
      models.Series.hasMany(Season, { foreignKey: 'seriesId' });

      Season.hasMany(models.Episode, { foreignKey: 'seasonId' });
      Season.hasMany(models.Rating, { foreignKey: 'seasonId' });
      Season.hasMany(models.WatchHistory, { foreignKey: 'seasonId' });
      Season.hasMany(models.Media, { foreignKey: 'seasonId' });

    }
  }
  Season.init({
    seriesId: DataTypes.INTEGER,
    seasonNumber: DataTypes.INTEGER,
    title: DataTypes.STRING,
    description: DataTypes.STRING,
    releaseDate: DataTypes.DATE,
    posterUrl: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'Season',
  });
  return Season;
};