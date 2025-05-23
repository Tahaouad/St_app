'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Supprimer l'ancienne table WatchHistories
    await queryInterface.dropTable('WatchHistories');
    
    // Créer la nouvelle table WatchHistories
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
      tmdbId: {
        type: Sequelize.INTEGER,
        allowNull: false
      },
      mediaType: {
        type: Sequelize.ENUM('movie', 'tv', 'episode'),
        allowNull: false
      },
      seasonNumber: {
        type: Sequelize.INTEGER
      },
      episodeNumber: {
        type: Sequelize.INTEGER
      },
      title: {
        type: Sequelize.STRING
      },
      posterPath: {
        type: Sequelize.STRING
      },
      watchedAt: {
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW
      },
      progress: {
        type: Sequelize.INTEGER, // en secondes
        defaultValue: 0
      },
      duration: {
        type: Sequelize.INTEGER // durée totale en secondes
      },
      completed: {
        type: Sequelize.BOOLEAN,
        defaultValue: false
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
    
    // Index pour les requêtes fréquentes
    await queryInterface.addIndex('WatchHistories', ['userId', 'watchedAt']);
    await queryInterface.addIndex('WatchHistories', ['userId', 'completed']);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('WatchHistories');
  }
};