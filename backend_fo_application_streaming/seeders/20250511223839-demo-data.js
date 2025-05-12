'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // 1. Catégories
    await queryInterface.bulkInsert('Categories', [
      {
        name: 'Action',
        description: 'Films et séries d\'action pleins d\'adrénaline',
        imageUrl: 'https://i.imgur.com/5cUQAYw.jpg',
        isActive: true,
        displayOrder: 1,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Drame',
        description: 'Histoires émouvantes et profondes',
        imageUrl: 'https://i.imgur.com/ThO8aLT.jpg',
        isActive: true,
        displayOrder: 3,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Science-Fiction',
        description: 'Aventures futuristes et technologiques',
        imageUrl: 'https://i.imgur.com/8KHWCcc.jpg',
        isActive: true,
        displayOrder: 4,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ], {});

    // 2. Genres
    await queryInterface.bulkInsert('Genres', [
      { name: 'Aventure', description: 'Voyages et découvertes', createdAt: new Date(), updatedAt: new Date() },
      { name: 'Romance', description: 'Histoires d\'amour', createdAt: new Date(), updatedAt: new Date() },
      { name: 'Policier', description: 'Enquêtes et mystères', createdAt: new Date(), updatedAt: new Date() },
      { name: 'Fantasy', description: 'Mondes imaginaires et magie', createdAt: new Date(), updatedAt: new Date() }
    ], {});

    // 3. Films
    await queryInterface.bulkInsert('Movies', [
      {
        title: 'Inception',
        description: 'Dom Cobb est un voleur expérimenté dans l\'art périlleux de l\'extraction : sa spécialité consiste à s\'approprier les secrets les plus précieux d\'un individu, enfouis au plus profond de son subconscient.',
        duration: 148,
        releaseYear: 2010,
        director: 'Christopher Nolan',
        cast: 'Leonardo DiCaprio, Joseph Gordon-Levitt, Ellen Page, Tom Hardy',
        ratingAVG: 8.8,
        posterUrl: 'https://m.media-amazon.com/images/M/MV5BMjAxMzY3NjcxNF5BMl5BanBnXkFtZTcwNTI5OTM0Mw@@._V1_.jpg',
        backdropUrl: 'https://i.imgur.com/rF44aiZ.jpg',
        trailerUrl: 'https://www.youtube.com/watch?v=YoHD9XEInc0',
        videoUrl: 'https://www.youtube.com/watch?v=YoHD9XEInc0',
        isActive: true,
        categoryId: 3, // Science-Fiction
        isFeatured: true,
        maturityRating: 'PG-13',
        viewCount: 1250,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        title: 'The Dark Knight',
        description: 'Batman se bat contre un criminel connu sous le nom du Joker qui cherche à plonger Gotham City dans l\'anarchie.',
        duration: 152,
        releaseYear: 2008,
        director: 'Christopher Nolan',
        cast: 'Christian Bale, Heath Ledger, Aaron Eckhart',
        ratingAVG: 9.0,
        posterUrl: 'https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_.jpg',
        backdropUrl: 'https://i.imgur.com/PfaYAkl.jpg',
        trailerUrl: 'https://www.youtube.com/watch?v=EXeTwQWrcwY',
        videoUrl: 'https://www.youtube.com/watch?v=EXeTwQWrcwY',
        isActive: true,
        categoryId: 1, // Action
        isFeatured: true,
        maturityRating: 'PG-13',
        viewCount: 1350,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ], {});

    // 4. Séries
    await queryInterface.bulkInsert('Series', [
      {
        title: 'Stranger Things',
        description: 'Quand un jeune garçon disparaît, une petite ville découvre une affaire mystérieuse, des expériences secrètes, des forces surnaturelles terrifiantes... et une étrange petite fille.',
        releaseYear: 2016,
        endYear: null,
        creator: 'Les frères Duffer',
        cast: 'Winona Ryder, David Harbour, Finn Wolfhard, Millie Bobby Brown',
        ratingAVG: 8.7,
        posterUrl: 'https://m.media-amazon.com/images/M/MV5BMDZkYmVhNjMtNWU4MC00MDQxLWE3MjYtZGMzZWI1ZjhlOWJmXkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_.jpg',
        backdropUrl: 'https://i.imgur.com/hJcuP1W.jpg',
        trailerUrl: 'https://www.youtube.com/watch?v=b9EkMc79ZSU',
        isActive: true,
        categoryId: 3, // Science-Fiction
        isFeatured: true,
        maturityRating: 'TV-14',
        status: 'ongoing',
        viewCount: 1850,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        title: 'Breaking Bad',
        description: 'Un professeur de chimie atteint d\'un cancer terminal s\'associe à un ancien élève pour fabriquer et vendre de la méthamphétamine afin d\'assurer l\'avenir financier de sa famille.',
        releaseYear: 2008,
        endYear: 2013,
        creator: 'Vince Gilligan',
        cast: 'Bryan Cranston, Aaron Paul, Anna Gunn',
        ratingAVG: 9.5,
        posterUrl: 'https://m.media-amazon.com/images/M/MV5BYmQ4YWMxYjUtNjZmYi00MDQ1LWFjMjMtNjA5ZDdiYjdiODU5XkEyXkFqcGdeQXVyMTMzNDExODE5._V1_.jpg',
        backdropUrl: 'https://i.imgur.com/HZ9NPzO.jpg',
        trailerUrl: 'https://www.youtube.com/watch?v=HhesaQXLuRY',
        isActive: true,
        categoryId: 2, // Drame
        isFeatured: true,
        maturityRating: 'TV-MA',
        status: 'completed',
        viewCount: 1650,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ], {});

    // 5. Saisons
    await queryInterface.bulkInsert('Seasons', [
      {
        seriesId: 1, // Stranger Things
        seasonNumber: 1,
        title: 'Stranger Things: Saison 1',
        description: 'La saison 1 commence avec la disparition d\'un jeune garçon nommé Will Byers et l\'arrivée mystérieuse d\'une fille aux pouvoirs télékinésiques.',
        releaseDate: new Date('2016-07-15'),
        posterUrl: 'https://m.media-amazon.com/images/M/MV5BN2ZmYjg1YmItNWQ4OC00YWM0LWE0ZDktYThjOTZiZjhhN2Q2XkEyXkFqcGdeQXVyNjgxNTQ3Mjk@._V1_.jpg',
        episodeCount: 8,
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        seriesId: 2, // Breaking Bad
        seasonNumber: 1,
        title: 'Breaking Bad: Saison 1',
        description: 'Walter White, professeur de chimie, apprend qu\'il est atteint d\'un cancer du poumon. Il commence à fabriquer de la méthamphétamine avec un ancien élève.',
        releaseDate: new Date('2008-01-20'),
        posterUrl: 'https://i.imgur.com/t4OlKh3.jpg',
        episodeCount: 7,
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ], {});

    // 6. Épisodes
    await queryInterface.bulkInsert('Episodes', [
      {
        seasonId: 1, // Stranger Things S1
        title: 'La disparition de Will Byers',
        description: 'Le jeune Will Byers disparaît mystérieusement, et une étrange jeune fille aux capacités surnaturelles apparaît.',
        duration: 48,
        episodeNumber: 1,
        videoUrl: 'https://www.youtube.com/watch?v=b9EkMc79ZSU',
        thumbnailUrl: 'https://i.imgur.com/qTLtCnP.jpg',
        releaseDate: new Date('2016-07-15'),
        isActive: true,
        viewCount: 1250,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        seasonId: 1, // Stranger Things S1
        title: 'La folle de Maple Street',
        description: 'Lucas, Mike et Dustin tentent d\'aider Eleven à s\'intégrer. Joyce est convaincue que Will tente de communiquer avec elle.',
        duration: 45,
        episodeNumber: 2,
        videoUrl: 'https://www.youtube.com/watch?v=b9EkMc79ZSU',
        thumbnailUrl: 'https://i.imgur.com/8NfUpP7.jpg',
        releaseDate: new Date('2016-07-15'),
        isActive: true,
        viewCount: 1150,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        seasonId: 2, // Breaking Bad S1
        title: 'Chute libre',
        description: 'Un professeur de chimie diagnostiqué avec un cancer inopérable décide de se tourner vers la fabrication de drogue pour assurer l\'avenir de sa famille.',
        duration: 58,
        episodeNumber: 1,
        videoUrl: 'https://www.youtube.com/watch?v=HhesaQXLuRY',
        thumbnailUrl: 'https://i.imgur.com/8F8UHS6.jpg',
        releaseDate: new Date('2008-01-20'),
        isActive: true,
        viewCount: 1450,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ], {});

    // 7. Associations films-genres
    await queryInterface.bulkInsert('MovieGenres', [
      { movieId: 1, genreId: 1, createdAt: new Date(), updatedAt: new Date() }, // Inception - Aventure
      { movieId: 1, genreId: 4, createdAt: new Date(), updatedAt: new Date() }, // Inception - Fantasy
      { movieId: 2, genreId: 1, createdAt: new Date(), updatedAt: new Date() }, // Dark Knight - Aventure
      { movieId: 2, genreId: 3, createdAt: new Date(), updatedAt: new Date() }  // Dark Knight - Policier
    ], {});

    // 8. Associations séries-genres
    await queryInterface.bulkInsert('SeriesGenres', [
      { seriesId: 1, genreId: 1, createdAt: new Date(), updatedAt: new Date() }, // Stranger Things - Aventure
      { seriesId: 1, genreId: 4, createdAt: new Date(), updatedAt: new Date() }, // Stranger Things - Fantasy
      { seriesId: 2, genreId: 3, createdAt: new Date(), updatedAt: new Date() }  // Breaking Bad - Policier
    ], {});

    // 9. Médias
    await queryInterface.bulkInsert('Media', [
      // Médias pour Inception
      {
        url: 'https://m.media-amazon.com/images/M/MV5BMjAxMzY3NjcxNF5BMl5BanBnXkFtZTcwNTI5OTM0Mw@@._V1_.jpg',
        type: 'poster',
        title: 'Affiche Inception',
        description: 'Affiche principale du film Inception',
        movieId: 1,
        seriesId: null,
        seasonId: null,
        episodeId: null,
        isDefault: true,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        url: 'https://i.imgur.com/rF44aiZ.jpg',
        type: 'backdrop',
        title: 'Backdrop Inception',
        description: 'Image de fond du film Inception',
        movieId: 1,
        seriesId: null,
        seasonId: null,
        episodeId: null,
        isDefault: true,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      // Médias pour Stranger Things
      {
        url: 'https://m.media-amazon.com/images/M/MV5BMDZkYmVhNjMtNWU4MC00MDQxLWE3MjYtZGMzZWI1ZjhlOWJmXkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_.jpg',
        type: 'poster',
        title: 'Affiche Stranger Things',
        description: 'Affiche principale de la série Stranger Things',
        movieId: null,
        seriesId: 1,
        seasonId: null,
        episodeId: null,
        isDefault: true,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ], {});

    // 10. Créer un utilisateur administrateur
    await queryInterface.bulkInsert('Users', [
      {
        name: 'Admin User',
        email: 'admin@example.com',
        password: '$2a$10$w35cKgqUcjHLWpUHZPc4oODq0gFOLPbwKvoFOhQ3WnWnK1XZ1qWYK', // 'password123'
        role: 'admin',
        avatar: 'https://api.dicebear.com/9.x/adventurer/svg?seed=Admin',
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Test User',
        email: 'user@example.com',
        password: '$2a$10$w35cKgqUcjHLWpUHZPc4oODq0gFOLPbwKvoFOhQ3WnWnK1XZ1qWYK', // 'password123'
        role: 'user',
        avatar: 'https://api.dicebear.com/9.x/adventurer/svg?seed=User',
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ], {});
  },

  down: async (queryInterface, Sequelize) => {
    // Supprimer les données dans l'ordre inverse de l'insertion pour éviter les erreurs de contrainte
    await queryInterface.bulkDelete('Media', null, {});
    await queryInterface.bulkDelete('SeriesGenres', null, {});
    await queryInterface.bulkDelete('MovieGenres', null, {});
    await queryInterface.bulkDelete('Episodes', null, {});
    await queryInterface.bulkDelete('Seasons', null, {});
    await queryInterface.bulkDelete('Series', null, {});
    await queryInterface.bulkDelete('Movies', null, {});
    await queryInterface.bulkDelete('Genres', null, {});
    await queryInterface.bulkDelete('Categories', null, {});
    await queryInterface.bulkDelete('Users', null, {});
  }
};