'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Supprimer l'ancienne table Ratings
    await queryInterface.dropTable('Ratings');
    
    // Créer la nouvelle table Ratings
    await queryInterface.createTable('Ratings', {
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
      rating: {
        type: Sequelize.INTEGER,
        allowNull: false,
        validate: {
          min: 1,
          max: 10
        }
      },
      comment: {
        type: Sequelize.TEXT
      },
      title: {
        type: Sequelize.STRING
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
    
    // Index pour éviter les doublons de notes
    await queryInterface.addIndex('Ratings', ['userId', 'tmdbId', 'mediaType', 'seasonNumber', 'episodeNumber'], {
      unique: true,
      name: 'user_rating_unique'
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Ratings');
  }
};
