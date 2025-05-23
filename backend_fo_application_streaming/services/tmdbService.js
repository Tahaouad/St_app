// backend_fo_application_streaming/services/tmdbService.js
const axios = require('axios');

class TMDBService {
  constructor() {
    this.baseURL = 'https://api.themoviedb.org/3';
    this.apiKey = process.env.TMDB_API_KEY;
    this.imageBaseURL = 'https://image.tmdb.org/t/p';
    
    // URLs des services de streaming
    this.streamingBaseURLs = {
      vidsrc: 'https://vidsrc.to/embed',
      embedsu: 'https://embed.su/embed',
      superembed: 'https://multiembed.mov/directstream.php'
    };
  }

  // Méthodes de recherche et découverte
  async searchMulti(query, page = 1) {
    const response = await axios.get(`${this.baseURL}/search/multi`, {
      params: {
        api_key: this.apiKey,
        query,
        page,
        language: 'fr-FR'
      }
    });
    return response.data;
  }

  async getPopularMovies(page = 1) {
    const response = await axios.get(`${this.baseURL}/movie/popular`, {
      params: {
        api_key: this.apiKey,
        page,
        language: 'fr-FR'
      }
    });
    return response.data;
  }

  async getPopularTV(page = 1) {
    const response = await axios.get(`${this.baseURL}/tv/popular`, {
      params: {
        api_key: this.apiKey,
        page,
        language: 'fr-FR'
      }
    });
    return response.data;
  }

  async getTrending(type = 'all', time = 'day', page = 1) {
    const response = await axios.get(`${this.baseURL}/trending/${type}/${time}`, {
      params: {
        api_key: this.apiKey,
        page,
        language: 'fr-FR'
      }
    });
    return response.data;
  }

  async getTopRated(type = 'movie', page = 1) {
    const response = await axios.get(`${this.baseURL}/${type}/top_rated`, {
      params: {
        api_key: this.apiKey,
        page,
        language: 'fr-FR'
      }
    });
    return response.data;
  }

  async getUpcoming(page = 1) {
    const response = await axios.get(`${this.baseURL}/movie/upcoming`, {
      params: {
        api_key: this.apiKey,
        page,
        language: 'fr-FR'
      }
    });
    return response.data;
  }

  // Méthodes de détails
  async getMovieDetails(id) {
    const response = await axios.get(`${this.baseURL}/movie/${id}`, {
      params: {
        api_key: this.apiKey,
        language: 'fr-FR',
        append_to_response: 'credits,videos,external_ids,recommendations,similar'
      }
    });
    return response.data;
  }

  async getTVDetails(id) {
    const response = await axios.get(`${this.baseURL}/tv/${id}`, {
      params: {
        api_key: this.apiKey,
        language: 'fr-FR',
        append_to_response: 'credits,videos,external_ids,recommendations,similar'
      }
    });
    return response.data;
  }

  async getSeasonDetails(tvId, seasonNumber) {
    const response = await axios.get(`${this.baseURL}/tv/${tvId}/season/${seasonNumber}`, {
      params: {
        api_key: this.apiKey,
        language: 'fr-FR'
      }
    });
    return response.data;
  }

  async getEpisodeDetails(tvId, seasonNumber, episodeNumber) {
    const response = await axios.get(`${this.baseURL}/tv/${tvId}/season/${seasonNumber}/episode/${episodeNumber}`, {
      params: {
        api_key: this.apiKey,
        language: 'fr-FR'
      }
    });
    return response.data;
  }

  // Méthodes de genres
  async getGenres(type = 'movie') {
    const response = await axios.get(`${this.baseURL}/genre/${type}/list`, {
      params: {
        api_key: this.apiKey,
        language: 'fr-FR'
      }
    });
    return response.data.genres;
  }

  async discoverByGenre(genreId, type = 'movie', page = 1) {
    const response = await axios.get(`${this.baseURL}/discover/${type}`, {
      params: {
        api_key: this.apiKey,
        with_genres: genreId,
        page,
        language: 'fr-FR'
      }
    });
    return response.data;
  }

  // Méthodes de streaming
 generateMovieStreamUrl(tmdbId, imdbId = null, options = {}) {
  const domains = ['vidsrc.xyz', 'vidsrc.cc', 'multiembed.mov'];
  const domain = domains[0];
  
  // URL principale avec fallback
  const params = new URLSearchParams();
  
  if (imdbId) {
    params.append('imdb', imdbId);
  } else {
    params.append('tmdb', tmdbId);
  }
  
  if (options.subtitle_lang) params.append('ds_lang', options.subtitle_lang);
  
  return `https://${domain}/embed/movie?${params.toString()}`;
}

generateEpisodeStreamUrl(tmdbId, season, episode, imdbId = null, options = {}) {
  const domains = ['vidsrc.xyz', 'vidsrc.cc', 'multiembed.mov'];
  const domain = domains[0];
  
  const params = new URLSearchParams();
  
  if (imdbId) {
    params.append('imdb', imdbId);
  } else {
    params.append('tmdb', tmdbId);
  }
  
  params.append('season', season);
  params.append('episode', episode);
  
  if (options.subtitle_lang) params.append('ds_lang', options.subtitle_lang);
  
  return `https://${domain}/embed/tv?${params.toString()}`;
}
  // Méthodes de formatage
  formatMovieForApp(movie) {
    return {
      ...movie,
      media_type: 'movie',
      poster_url: this.getImageUrl(movie.poster_path),
      backdrop_url: this.getImageUrl(movie.backdrop_path, 'w1280')
    };
  }
  

  formatTVForApp(tv) {
    return {
      ...tv,
      media_type: 'tv',
      title: tv.name, // Ajouter title pour compatibilité
      poster_url: this.getImageUrl(tv.poster_path),
      backdrop_url: this.getImageUrl(tv.backdrop_path, 'w1280')
    };
  }

  // Méthodes utilitaires
  getImageUrl(path, size = 'w500') {
    if (!path) return null;
    return `${this.imageBaseURL}/${size}${path}`;
  }

  async getIMDBId(titleOrId) {
    // Si c'est déjà un ID IMDB, le retourner
    if (typeof titleOrId === 'string' && titleOrId.startsWith('tt')) {
      return titleOrId;
    }
    
    // Sinon, essayer de chercher par titre
    try {
      const searchResults = await this.searchMulti(titleOrId, 1);
      if (searchResults.results && searchResults.results.length > 0) {
        const firstResult = searchResults.results[0];
        
        // Obtenir les détails pour récupérer l'IMDB ID
        let details;
        if (firstResult.media_type === 'movie') {
          details = await this.getMovieDetails(firstResult.id);
        } else if (firstResult.media_type === 'tv') {
          details = await this.getTVDetails(firstResult.id);
        }
        
        return details?.external_ids?.imdb_id || null;
      }
    } catch (error) {
      console.error('Erreur lors de la récupération de l\'IMDB ID:', error);
    }
    
    return null;
  }

  // Méthodes alternatives pour différents services de streaming
  getAlternativeStreamUrls(tmdbId, type = 'movie', season = null, episode = null) {
    const urls = [];
    
    if (type === 'movie') {
      // VidSrc
      urls.push({
        service: 'VidSrc',
        url: `${this.streamingBaseURLs.vidsrc}/movie/${tmdbId}`,
        quality: 'HD'
      });
      
      // Embed.su
      urls.push({
        service: 'Embed.su',
        url: `${this.streamingBaseURLs.embedsu}/movie/${tmdbId}`,
        quality: 'HD'
      });
      
      // SuperEmbed
      urls.push({
        service: 'SuperEmbed',
        url: `${this.streamingBaseURLs.superembed}?video_id=${tmdbId}&tmdb=1`,
        quality: 'HD'
      });
    } else if (type === 'tv' && season && episode) {
      // VidSrc pour séries
      urls.push({
        service: 'VidSrc',
        url: `${this.streamingBaseURLs.vidsrc}/tv/${tmdbId}/${season}/${episode}`,
        quality: 'HD'
      });
      
      // Embed.su pour séries
      urls.push({
        service: 'Embed.su',
        url: `${this.streamingBaseURLs.embedsu}/tv/${tmdbId}/${season}/${episode}`,
        quality: 'HD'
      });
    }
    
    return urls;
  }

  // Vérifier la disponibilité d'un service de streaming
  async checkStreamAvailability(url) {
    try {
      const response = await axios.head(url, { timeout: 5000 });
      return response.status === 200;
    } catch (error) {
      return false;
    }
  }
}

module.exports = new TMDBService();