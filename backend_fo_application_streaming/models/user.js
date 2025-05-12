'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class User extends Model {
    static associate(models) {
      User.hasMany(models.Favorite, { foreignKey: 'userId' });
      User.hasMany(models.Rating, { foreignKey: 'userId' });
      User.hasMany(models.WatchHistory, { foreignKey: 'userId' });
    }
  }
  
  User.init({
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true
      }
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false
    },
    role: {
      type: DataTypes.ENUM('user', 'admin', 'moderator'),
      defaultValue: 'user'
    },
    avatar: {
      type: DataTypes.STRING,
      defaultValue: 'https://api.dicebear.com/9.x/adventurer/svg?seed=Emery'
    }
  }, {
    sequelize,
    modelName: 'User',
    timestamps: true
  });
  
  return User;
};