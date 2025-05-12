'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('SeriesGenres', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      seriesId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'Series',
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
    await queryInterface.addIndex('SeriesGenres', ['seriesId', 'genreId'], {
      unique: true,
      name: 'series_genre_unique'
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('SeriesGenres');
  }
};