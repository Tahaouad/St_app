const axios = require('axios');

class TMDBService {
  constructor() {
    this.apiKey = process.env.TMDB_API_KEY;
    this.baseUrl = 'https://api.themoviedb.org/3';
    this.imageBaseUrl = 'https://image.tmdb.org/t/p';
    this.imdbServiceUrl = process.env.IMDB_SERVICE_URL || 'http://localhost:3000';
    this.vidsrcDomains = ['vidsrc.xyz', 'vidsrc.in', 'vidsrc.pm', 'vidsrc.net'];
  }

  // === RECHERCHE ET DÉCOUVERTE ===

  async searchMulti(query, page = 1) {
    try {
      const response = await axios.get(`${this.baseUrl}/search/multi`, {
        params: {
          api_key: this.apiKey,
          query,
          page,
          language: 'fr-FR'
        }
      });
      return response.data;
    } catch (error) {
      throw new Error(`Erreur recherche: ${error.message}`);
    }
  }

  async getPopularMovies(page = 1) {
    try {
      const response = await axios.get(`${this.baseUrl}/movie/popular`, {
        params: {
          api_key: this.apiKey,
          page,
          language: 'fr-FR'
        }
      });
      return response.data;
    } catch (error) {
      throw new Error(`Erreur films populaires: ${error.message}`);
    }
  }

  async getPopularTV(page = 1) {
    try {
      const response = await axios.get(`${this.baseUrl}/tv/popular`, {
        params: {
          api_key: this.apiKey,
          page,
          language: 'fr-FR'
        }
      });
      return response.data;
    } catch (error) {
      throw new Error(`Erreur séries populaires: ${error.message}`);
    }
  }

  async getTrending(mediaType = 'all', timeWindow = 'day', page = 1) {
    try {
      const response = await axios.get(`${this.baseUrl}/trending/${mediaType}/${timeWindow}`, {
        params: {
          api_key: this.apiKey,
          page,
          language: 'fr-FR'
        }
      });
      return response.data;
    } catch (error) {
      throw new Error(`Erreur trending: ${error.message}`);
    }
  }

  async getTopRated(mediaType = 'movie', page = 1) {
    try {
      const response = await axios.get(`${this.baseUrl}/${mediaType}/top_rated`, {
        params: {
          api_key: this.apiKey,
          page,
          language: 'fr-FR'
        }
      });
      return response.data;
    } catch (error) {
      throw new Error(`Erreur top rated: ${error.message}`);
    }
  }

  async getUpcoming(page = 1) {
    try {
      const response = await axios.get(`${this.baseUrl}/movie/upcoming`, {
        params: {
          api_key: this.apiKey,
          page,
          language: 'fr-FR'
        }
      });
      return response.data;
    } catch (error) {
      throw new Error(`Erreur upcoming: ${error.message}`);
    }
  }

  // === DÉTAILS CONTENU ===

  async getMovieDetails(movieId) {
    try {
      const response = await axios.get(`${this.baseUrl}/movie/${movieId}`, {
        params: {
          api_key: this.apiKey,
          append_to_response: 'credits,videos,external_ids,recommendations,similar',
          language: 'fr-FR'
        }
      });
      return response.data;
    } catch (error) {
      throw new Error(`Erreur détails film: ${error.message}`);
    }
  }

  async getTVDetails(tvId) {
    try {
      const response = await axios.get(`${this.baseUrl}/tv/${tvId}`, {
        params: {
          api_key: this.apiKey,
          append_to_response: 'credits,videos,external_ids,recommendations,similar',
          language: 'fr-FR'
        }
      });
      return response.data;
    } catch (error) {
      throw new Error(`Erreur détails série: ${error.message}`);
    }
  }

  async getSeasonDetails(tvId, seasonNumber) {
    try {
      const response = await axios.get(`${this.baseUrl}/tv/${tvId}/season/${seasonNumber}`, {
        params: {
          api_key: this.apiKey,
          language: 'fr-FR'
        }
      });
      return response.data;
    } catch (error) {
      throw new Error(`Erreur détails saison: ${error.message}`);
    }
  }

  async getEpisodeDetails(tvId, seasonNumber, episodeNumber) {
    try {
      const response = await axios.get(`${this.baseUrl}/tv/${tvId}/season/${seasonNumber}/episode/${episodeNumber}`, {
        params: {
          api_key: this.apiKey,
          language: 'fr-FR'
        }
      });
      return response.data;
    } catch (error) {
      throw new Error(`Erreur détails épisode: ${error.message}`);
    }
  }

  // === GENRES ===

  async getGenres(mediaType = 'movie') {
    try {
      const response = await axios.get(`${this.baseUrl}/genre/${mediaType}/list`, {
        params: {
          api_key: this.apiKey,
          language: 'fr-FR'
        }
      });
      return response.data.genres;
    } catch (error) {
      throw new Error(`Erreur genres: ${error.message}`);
    }
  }

  async discoverByGenre(genreId, mediaType = 'movie', page = 1) {
    try {
      const response = await axios.get(`${this.baseUrl}/discover/${mediaType}`, {
        params: {
          api_key: this.apiKey,
          with_genres: genreId,
          page,
          language: 'fr-FR'
        }
      });
      return response.data;
    } catch (error) {
      throw new Error(`Erreur découverte par genre: ${error.message}`);
    }
  }

  // === STREAMING URLs ===

  async getIMDBId(title) {
    try {
      const response = await axios.post(`${this.imdbServiceUrl}/get-imdb-id`, { title });
      return response.data.imdbID;
    } catch (error) {
      console.warn(`IMDB ID non trouvé pour: ${title}`);
      return null;
    }
  }

  generateMovieStreamUrl(tmdbId, imdbId = null, options = {}) {
    const domain = this.vidsrcDomains[0];
    const params = new URLSearchParams();
    
    if (imdbId) {
      params.append('imdb', imdbId);
    } else {
      params.append('tmdb', tmdbId);
    }
    
    if (options.subtitle_lang) params.append('ds_lang', options.subtitle_lang);
    if (options.subtitle_url) params.append('sub_url', encodeURIComponent(options.subtitle_url));
    
    return `https://${domain}/embed/movie?${params.toString()}`;
  }

  generateEpisodeStreamUrl(tmdbId, season, episode, imdbId = null, options = {}) {
    const domain = this.vidsrcDomains[0];
    const params = new URLSearchParams();
    
    if (imdbId) {
      params.append('imdb', imdbId);
    } else {
      params.append('tmdb', tmdbId);
    }
    
    params.append('season', season);
    params.append('episode', episode);
    
    if (options.subtitle_lang) params.append('ds_lang', options.subtitle_lang);
    if (options.subtitle_url) params.append('sub_url', encodeURIComponent(options.subtitle_url));
    
    return `https://${domain}/embed/tv?${params.toString()}`;
  }

  // === UTILITAIRES ===

  getImageUrl(path, size = 'w500') {
    if (!path) return null;
    return `${this.imageBaseUrl}/${size}${path}`;
  }

  formatMovieForApp(movie) {
    return {
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      poster_path: movie.poster_path,
      backdrop_path: movie.backdrop_path,
      release_date: movie.release_date,
      vote_average: movie.vote_average,
      vote_count: movie.vote_count,
      genre_ids: movie.genre_ids,
      adult: movie.adult,
      media_type: 'movie',
      // URLs d'images complètes
      poster_url: this.getImageUrl(movie.poster_path),
      backdrop_url: this.getImageUrl(movie.backdrop_path, 'w1280')
    };
  }

  formatTVForApp(tv) {
    return {
      id: tv.id,
      name: tv.name,
      title: tv.name, // Alias pour uniformité
      overview: tv.overview,
      poster_path: tv.poster_path,
      backdrop_path: tv.backdrop_path,
      first_air_date: tv.first_air_date,
      vote_average: tv.vote_average,
      vote_count: tv.vote_count,
      genre_ids: tv.genre_ids,
      media_type: 'tv',
      // URLs d'images complètes
      poster_url: this.getImageUrl(tv.poster_path),
      backdrop_url: this.getImageUrl(tv.backdrop_path, 'w1280')
    };
  }
}

module.exports = new TMDBService();