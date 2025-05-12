'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Series', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      title: {
        type: Sequelize.STRING,
        allowNull: false
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: false
      },
      releaseYear: {
        type: Sequelize.INTEGER,
        allowNull: false
      },
      endYear: {
        type: Sequelize.INTEGER
      },
      creator: {
        type: Sequelize.STRING
      },
      cast: {
        type: Sequelize.TEXT
      },
      ratingAVG: {
        type: Sequelize.FLOAT,
        defaultValue: 0
      },
      posterUrl: {
        type: Sequelize.STRING
      },
      backdropUrl: {
        type: Sequelize.STRING
      },
      trailerUrl: {
        type: Sequelize.STRING
      },
      isActive: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
      },
      categoryId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'Categories',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      isFeatured: {
        type: Sequelize.BOOLEAN,
        defaultValue: false
      },
      maturityRating: {
        type: Sequelize.STRING,
        defaultValue: 'PG'
      },
      status: {
        type: Sequelize.ENUM('ongoing', 'completed', 'cancelled'),
        defaultValue: 'ongoing'
      },
      viewCount: {
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
    await queryInterface.dropTable('Series');
  }
};