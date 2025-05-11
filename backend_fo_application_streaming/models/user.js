'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class User extends Model {
    
    static associate(models) {
      User.hasMany(models.Favorite, { foreignKey: 'userId' });
      User.hasMany(models.Rating, { foreignKey: 'userId' });   
      User.hasMany(models.WatchHistory, { foreignKey: 'userId' });

    }
  }
  User.init({
   
    
    name: DataTypes.STRING,
    email: DataTypes.STRING,
    password: DataTypes.STRING,
    role : DataTypes.STRING,
    avatar:  DataTypes.STRING, 
    

  }, {
    sequelize,
    modelName: 'User',
  });
  return User;
};