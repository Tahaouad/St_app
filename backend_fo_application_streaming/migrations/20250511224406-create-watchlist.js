'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Watchlists', {
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
        type: Sequelize.ENUM('movie', 'tv'),
        allowNull: false
      },
      title: {
        type: Sequelize.STRING,
        allowNull: false
      },
      posterPath: {
        type: Sequelize.STRING
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
    
    // Index unique pour éviter les doublons
    await queryInterface.addIndex('Watchlists', ['userId', 'tmdbId', 'mediaType'], {
      unique: true,
      name: 'user_content_unique'
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Watchlists');
  }
};
