'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('WatchHistories', {
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
      seasonId: {
        type: Sequelize.INTEGER,
        references: {
          model: 'Seasons',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      episodeId: {
        type: Sequelize.INTEGER,
        references: {
          model: 'Episodes',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      watchedAt: {
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW
      },
      progress: {
        type: Sequelize.INTEGER,
        defaultValue: 0
      },
      completed: {
        type: Sequelize.BOOLEAN,
        defaultValue: false
      },
      watchDuration: {
        type: Sequelize.INTEGER,
        defaultValue: 0
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
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('WatchHistories');
  }
};