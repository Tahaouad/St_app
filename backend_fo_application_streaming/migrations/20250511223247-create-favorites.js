'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Favorites', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      userId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'Users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      movieId: {
        type: Sequelize.INTEGER,
        references: {
          model: 'Movies',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      seriesId: {
        type: Sequelize.INTEGER,
        references: {
          model: 'Series',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      addedAt: {
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW
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
    
    // Ajouter des index uniques pour éviter les doublons
    await queryInterface.addIndex('Favorites', ['userId', 'movieId'], {
      unique: true,
      name: 'user_movie_unique',
      where: {
        movieId: {
          [Sequelize.Op.ne]: null
        }
      }
    });
    
    await queryInterface.addIndex('Favorites', ['userId', 'seriesId'], {
      unique: true,
      name: 'user_series_unique',
      where: {
        seriesId: {
          [Sequelize.Op.ne]: null
        }
      }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Favorites');
  }
};