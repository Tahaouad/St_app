'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('MovieGenres', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      movieId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'Movies',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      genreId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'Genres',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE
      }
    });
    
    // Ajouter un index unique pour éviter les doublons
    await queryInterface.addIndex('MovieGenres', ['movieId', 'genreId'], {
      unique: true,
      name: 'movie_genre_unique'
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('MovieGenres');
  }
};