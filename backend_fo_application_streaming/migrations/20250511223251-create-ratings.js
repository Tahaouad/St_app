'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
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
      isRecommended: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
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
    
    // Ajouter des index uniques pour éviter les doublons par utilisateur et contenu
    await queryInterface.addIndex('Ratings', ['userId', 'movieId'], {
      unique: true,
      name: 'user_movie_rating_unique',
      where: {
        movieId: {
          [Sequelize.Op.ne]: null
        }
      }
    });
    
    await queryInterface.addIndex('Ratings', ['userId', 'seriesId'], {
      unique: true,
      name: 'user_series_rating_unique',
      where: {
        seriesId: {
          [Sequelize.Op.ne]: null
        },
        seasonId: null,
        episodeId: null
      }
    });
    
    await queryInterface.addIndex('Ratings', ['userId', 'seasonId'], {
      unique: true,
      name: 'user_season_rating_unique',
      where: {
        seasonId: {
          [Sequelize.Op.ne]: null
        },
        episodeId: null
      }
    });
    
    await queryInterface.addIndex('Ratings', ['userId', 'episodeId'], {
      unique: true,
      name: 'user_episode_rating_unique',
      where: {
        episodeId: {
          [Sequelize.Op.ne]: null
        }
      }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Ratings');
  }
};