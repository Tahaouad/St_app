const tmdbService = require('../services/tmdbService');

// === DÉCOUVERTE ET RECHERCHE ===

const search = async (req, res) => {
  try {
    const { query, page = 1 } = req.query;
    
    if (!query) {
      return res.status(400).json({ message: "Query requise" });
    }
    
    const results = await tmdbService.searchMulti(query, page);
    
    // Formater les résultats
    const formattedResults = results.results.map(item => {
      if (item.media_type === 'movie') {
        return tmdbService.formatMovieForApp(item);
      } else if (item.media_type === 'tv') {
        return tmdbService.formatTVForApp(item);
      }
      return item;
    }).filter(Boolean);
    
    res.json({
      ...results,
      results: formattedResults
    });
    
  } catch (error) {
    console.error('Erreur recherche:', error);
    res.status(500).json({ message: "Erreur de recherche", error: error.message });
  }
};

const getPopular = async (req, res) => {
  try {
    const { type = 'movie', page = 1 } = req.query;
    
    let results;
    if (type === 'movie') {
      results = await tmdbService.getPopularMovies(page);
      results.results = results.results.map(movie => tmdbService.formatMovieForApp(movie));
    } else if (type === 'tv') {
      results = await tmdbService.getPopularTV(page);
      results.results = results.results.map(tv => tmdbService.formatTVForApp(tv));
    }
    
    res.json(results);
    
  } catch (error) {
    console.error('Erreur popular:', error);
    res.status(500).json({ message: "Erreur contenu populaire", error: error.message });
  }
};

const getTrending = async (req, res) => {
  try {
    const { type = 'all', time = 'day', page = 1 } = req.query;
    
    const results = await tmdbService.getTrending(type, time, page);
    
    // Formater selon le type
    const formattedResults = results.results.map(item => {
      if (item.media_type === 'movie') {
        return tmdbService.formatMovieForApp(item);
      } else if (item.media_type === 'tv') {
        return tmdbService.formatTVForApp(item);
      }
      return item;
    });
    
    res.json({
      ...results,
      results: formattedResults
    });
    
  } catch (error) {
    console.error('Erreur trending:', error);
    res.status(500).json({ message: "Erreur contenu trending", error: error.message });
  }
};

const getTopRated = async (req, res) => {
  try {
    const { type = 'movie', page = 1 } = req.query;
    
    const results = await tmdbService.getTopRated(type, page);
    
    if (type === 'movie') {
      results.results = results.results.map(movie => tmdbService.formatMovieForApp(movie));
    } else {
      results.results = results.results.map(tv => tmdbService.formatTVForApp(tv));
    }
    
    res.json(results);
    
  } catch (error) {
    console.error('Erreur top rated:', error);
    res.status(500).json({ message: "Erreur top rated", error: error.message });
  }
};

const getUpcoming = async (req, res) => {
  try {
    const { page = 1 } = req.query;
    
    const results = await tmdbService.getUpcoming(page);
    results.results = results.results.map(movie => tmdbService.formatMovieForApp(movie));
    
    res.json(results);
    
  } catch (error) {
    console.error('Erreur upcoming:', error);
    res.status(500).json({ message: "Erreur films à venir", error: error.message });
  }
};

// === DÉTAILS ===

const getMovieDetails = async (req, res) => {
  try {
    const { id } = req.params;
    
    const movie = await tmdbService.getMovieDetails(id);
    
    // Enrichir avec URLs complètes
    const enrichedMovie = {
      ...movie,
      poster_url: tmdbService.getImageUrl(movie.poster_path),
      backdrop_url: tmdbService.getImageUrl(movie.backdrop_path, 'w1280'),
      media_type: 'movie'
    };
    
    res.json(enrichedMovie);
    
  } catch (error) {
    if (error.response?.status === 404) {
      return res.status(404).json({ message: "Film non trouvé" });
    }
    console.error('Erreur détails film:', error);
    res.status(500).json({ message: "Erreur détails film", error: error.message });
  }
};

const getTVDetails = async (req, res) => {
  try {
    const { id } = req.params;
    
    const tv = await tmdbService.getTVDetails(id);
    
    // Enrichir avec URLs complètes
    const enrichedTV = {
      ...tv,
      poster_url: tmdbService.getImageUrl(tv.poster_path),
      backdrop_url: tmdbService.getImageUrl(tv.backdrop_path, 'w1280'),
      media_type: 'tv'
    };
    
    res.json(enrichedTV);
    
  } catch (error) {
    if (error.response?.status === 404) {
      return res.status(404).json({ message: "Série non trouvée" });
    }
    console.error('Erreur détails série:', error);
    res.status(500).json({ message: "Erreur détails série", error: error.message });
  }
};

const getSeasonDetails = async (req, res) => {
  try {
    const { tvId, seasonNumber } = req.params;
    
    const season = await tmdbService.getSeasonDetails(tvId, seasonNumber);
    
    // Enrichir les épisodes avec URLs d'images
    const enrichedSeason = {
      ...season,
      poster_url: tmdbService.getImageUrl(season.poster_path),
      episodes: season.episodes.map(episode => ({
        ...episode,
        still_url: tmdbService.getImageUrl(episode.still_path)
      }))
    };
    
    res.json(enrichedSeason);
    
  } catch (error) {
    if (error.response?.status === 404) {
      return res.status(404).json({ message: "Saison non trouvée" });
    }
    console.error('Erreur détails saison:', error);
    res.status(500).json({ message: "Erreur détails saison", error: error.message });
  }
};

const getEpisodeDetails = async (req, res) => {
  try {
    const { tvId, seasonNumber, episodeNumber } = req.params;
    
    const episode = await tmdbService.getEpisodeDetails(tvId, seasonNumber, episodeNumber);
    
    const enrichedEpisode = {
      ...episode,
      still_url: tmdbService.getImageUrl(episode.still_path)
    };
    
    res.json(enrichedEpisode);
    
  } catch (error) {
    if (error.response?.status === 404) {
      return res.status(404).json({ message: "Épisode non trouvé" });
    }
    console.error('Erreur détails épisode:', error);
    res.status(500).json({ message: "Erreur détails épisode", error: error.message });
  }
};

// === GENRES ===

const getGenres = async (req, res) => {
  try {
    const { type = 'movie' } = req.query;
    
    const genres = await tmdbService.getGenres(type);
    
    res.json({ genres });
    
  } catch (error) {
    console.error('Erreur genres:', error);
    res.status(500).json({ message: "Erreur genres", error: error.message });
  }
};

const discoverByGenre = async (req, res) => {
  try {
    const { genreId } = req.params;
    const { type = 'movie', page = 1 } = req.query;
    
    const results = await tmdbService.discoverByGenre(genreId, type, page);
    
    if (type === 'movie') {
      results.results = results.results.map(movie => tmdbService.formatMovieForApp(movie));
    } else {
      results.results = results.results.map(tv => tmdbService.formatTVForApp(tv));
    }
    
    res.json(results);
    
  } catch (error) {
    console.error('Erreur découverte genre:', error);
    res.status(500).json({ message: "Erreur découverte par genre", error: error.message });
  }
};

// === STREAMING ===

const getStreamUrl = async (req, res) => {
  try {
    const { type, id } = req.params;
    const { season, episode, subtitle_lang, subtitle_url } = req.query;
    
    let streamUrl;
    let title = "Contenu";
    
    if (type === 'movie') {
      // Récupérer le titre pour obtenir l'IMDB ID
      const movieDetails = await tmdbService.getMovieDetails(id);
      const imdbId = movieDetails.external_ids?.imdb_id || 
                    await tmdbService.getIMDBId(movieDetails.title);
      
      streamUrl = tmdbService.generateMovieStreamUrl(id, imdbId, {
        subtitle_lang,
        subtitle_url
      });
      title = movieDetails.title;
      
    } else if (type === 'tv' && season && episode) {
      // Épisode spécifique
      const tvDetails = await tmdbService.getTVDetails(id);
      const imdbId = tvDetails.external_ids?.imdb_id || 
                    await tmdbService.getIMDBId(tvDetails.name);
      
      streamUrl = tmdbService.generateEpisodeStreamUrl(id, season, episode, imdbId, {
        subtitle_lang,
        subtitle_url
      });
      title = `${tvDetails.name} - S${season}E${episode}`;
      
    } else {
      return res.status(400).json({ 
        message: "Paramètres invalides. Pour les séries, 'season' et 'episode' sont requis." 
      });
    }
    
    res.json({
      tmdbId: id,
      mediaType: type,
      title,
      streamUrl,
      ...(season && { season: parseInt(season) }),
      ...(episode && { episode: parseInt(episode) })
    });
    
  } catch (error) {
    console.error('Erreur stream URL:', error);
    res.status(500).json({ message: "Erreur génération URL streaming", error: error.message });
  }
};

module.exports = {
  search,
  getPopular,
  getTrending,
  getTopRated,
  getUpcoming,
  getMovieDetails,
  getTVDetails,
  getSeasonDetails,
  getEpisodeDetails,
  getGenres,
  discoverByGenre,
  getStreamUrl
};