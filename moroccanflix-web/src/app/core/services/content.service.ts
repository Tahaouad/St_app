// src/app/core/services/content.service.ts
import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, BehaviorSubject, catchError, of, forkJoin } from 'rxjs';
import { map, tap } from 'rxjs/operators';
import { environment } from '../../../environments/environment';

// Interfaces basées sur votre API TMDB (identiques au Flutter)
export interface TMDBContent {
  id: number;
  title?: string; // Pour les films
  name?: string; // Pour les séries
  overview: string;
  poster_path: string;
  backdrop_path: string;
  poster_url?: string;
  backdrop_url?: string;
  release_date?: string; // Films
  first_air_date?: string; // Séries
  vote_average: number;
  vote_count: number;
  popularity: number;
  genre_ids: number[];
  genres?: Genre[];
  adult: boolean;
  original_language: string;
  media_type?: 'movie' | 'tv';
  runtime?: number;
  number_of_seasons?: number;
  number_of_episodes?: number;
  imdb_id?: string;
  external_ids?: {
    imdb_id: string;
  };
}

export interface Genre {
  id: number;
  name: string;
}

export interface TMDBResponse<T> {
  page: number;
  results: T[];
  total_pages: number;
  total_results: number;
}

export interface SeasonDetails {
  id: number;
  air_date: string;
  episodes: EpisodeDetails[];
  name: string;
  overview: string;
  poster_path: string;
  poster_url?: string;
  season_number: number;
  vote_average: number;
}

export interface EpisodeDetails {
  id: number;
  name: string;
  overview: string;
  air_date: string;
  episode_number: number;
  season_number: number;
  still_path: string;
  still_url?: string;
  vote_average: number;
  vote_count: number;
  runtime: number;
}

export interface StreamInfo {
  tmdbId: number;
  mediaType: 'movie' | 'tv';
  title: string;
  streamUrl: string;
  season?: number;
  episode?: number;
}

@Injectable({
  providedIn: 'root'
})
export class ContentService {
  private readonly apiUrl = `${environment.apiUrl}/content`;
  
  // Cache pour optimiser les requêtes
  private cache = new Map<string, any>();
  
  // État global du contenu (comme dans Flutter)
  private trendingContent$ = new BehaviorSubject<TMDBContent[]>([]);
  private popularMovies$ = new BehaviorSubject<TMDBContent[]>([]);
  private popularSeries$ = new BehaviorSubject<TMDBContent[]>([]);
  private topRatedMovies$ = new BehaviorSubject<TMDBContent[]>([]);
  private upcomingMovies$ = new BehaviorSubject<TMDBContent[]>([]);
  private genres$ = new BehaviorSubject<Genre[]>([]);

  // Observables publics
  public trendingContent = this.trendingContent$.asObservable();
  public popularMovies = this.popularMovies$.asObservable();
  public popularSeries = this.popularSeries$.asObservable();
  public topRatedMovies = this.topRatedMovies$.asObservable();
  public upcomingMovies = this.upcomingMovies$.asObservable();
  public genres = this.genres$.asObservable();

  constructor(private http: HttpClient) {
    console.log('🎬 Content Service (TMDB) initialisé');
    this.loadInitialContent();
  }

  // ================================================================
  // CHARGEMENT INITIAL DU CONTENU (comme Flutter)
  // ================================================================

  private loadInitialContent(): void {
    forkJoin({
      trending: this.getTrending('all', 'day'),
      popularMovies: this.getPopular('movie'),
      popularSeries: this.getPopular('tv'),
      topRated: this.getTopRated('movie'),
      upcoming: this.getUpcoming(),
      genres: this.getGenres('movie')
    }).subscribe({
      next: (data) => {
        this.trendingContent$.next(data.trending.results || []);
        this.popularMovies$.next(data.popularMovies.results || []);
        this.popularSeries$.next(data.popularSeries.results || []);
        this.topRatedMovies$.next(data.topRated.results || []);
        this.upcomingMovies$.next(data.upcoming.results || []);
        this.genres$.next(data.genres.genres || []);
        console.log('✅ Contenu initial chargé:', {
          trending: data.trending.results?.length,
          movies: data.popularMovies.results?.length,
          series: data.popularSeries.results?.length
        });
      },
      error: (error) => {
        console.error('❌ Erreur chargement initial:', error);
      }
    });
  }

  // ================================================================
  // MÉTHODES API (identiques au backend Flutter)
  // ================================================================

  search(query: string, page: number = 1): Observable<TMDBResponse<TMDBContent>> {
    const params = new HttpParams()
      .set('query', query)
      .set('page', page.toString());

    return this.http.get<TMDBResponse<TMDBContent>>(`${this.apiUrl}/search`, { params })
      .pipe(
        map(response => this.enrichContentUrls(response)),
        catchError(error => {
          console.error('❌ Erreur recherche:', error);
          return of({ page: 1, results: [], total_pages: 0, total_results: 0 });
        })
      );
  }

  getTrending(type: 'all' | 'movie' | 'tv' = 'all', time: 'day' | 'week' = 'day', page: number = 1): Observable<TMDBResponse<TMDBContent>> {
    const params = new HttpParams()
      .set('type', type)
      .set('time', time)
      .set('page', page.toString());

    return this.http.get<TMDBResponse<TMDBContent>>(`${this.apiUrl}/trending`, { params })
      .pipe(
        map(response => this.enrichContentUrls(response)),
        catchError(error => {
          console.error('❌ Erreur trending:', error);
          return of({ page: 1, results: [], total_pages: 0, total_results: 0 });
        })
      );
  }

  getPopular(type: 'movie' | 'tv', page: number = 1): Observable<TMDBResponse<TMDBContent>> {
    const params = new HttpParams()
      .set('type', type)
      .set('page', page.toString());

    return this.http.get<TMDBResponse<TMDBContent>>(`${this.apiUrl}/popular`, { params })
      .pipe(
        map(response => this.enrichContentUrls(response)),
        catchError(error => {
          console.error('❌ Erreur popular:', error);
          return of({ page: 1, results: [], total_pages: 0, total_results: 0 });
        })
      );
  }

  getTopRated(type: 'movie' | 'tv', page: number = 1): Observable<TMDBResponse<TMDBContent>> {
    const params = new HttpParams()
      .set('type', type)
      .set('page', page.toString());

    return this.http.get<TMDBResponse<TMDBContent>>(`${this.apiUrl}/top-rated`, { params })
      .pipe(
        map(response => this.enrichContentUrls(response)),
        catchError(error => {
          console.error('❌ Erreur top rated:', error);
          return of({ page: 1, results: [], total_pages: 0, total_results: 0 });
        })
      );
  }

  getUpcoming(page: number = 1): Observable<TMDBResponse<TMDBContent>> {
    const params = new HttpParams().set('page', page.toString());

    return this.http.get<TMDBResponse<TMDBContent>>(`${this.apiUrl}/upcoming`, { params })
      .pipe(
        map(response => this.enrichContentUrls(response)),
        catchError(error => {
          console.error('❌ Erreur upcoming:', error);
          return of({ page: 1, results: [], total_pages: 0, total_results: 0 });
        })
      );
  }

  // ================================================================
  // DÉTAILS DU CONTENU
  // ================================================================

  getMovieDetails(id: number): Observable<TMDBContent> {
    const cacheKey = `movie_${id}`;
    
    if (this.cache.has(cacheKey)) {
      return of(this.cache.get(cacheKey));
    }

    return this.http.get<TMDBContent>(`${this.apiUrl}/movie/${id}`)
      .pipe(
        map(movie => this.enrichSingleContent(movie)),
        tap(movie => this.cache.set(cacheKey, movie)),
        catchError(error => {
          console.error('❌ Erreur détails film:', error);
          throw error;
        })
      );
  }

  getTVDetails(id: number): Observable<TMDBContent> {
    const cacheKey = `tv_${id}`;
    
    if (this.cache.has(cacheKey)) {
      return of(this.cache.get(cacheKey));
    }

    return this.http.get<TMDBContent>(`${this.apiUrl}/tv/${id}`)
      .pipe(
        map(tv => this.enrichSingleContent(tv)),
        tap(tv => this.cache.set(cacheKey, tv)),
        catchError(error => {
          console.error('❌ Erreur détails série:', error);
          throw error;
        })
      );
  }

  getSeasonDetails(tvId: number, seasonNumber: number): Observable<SeasonDetails> {
    const cacheKey = `season_${tvId}_${seasonNumber}`;
    
    if (this.cache.has(cacheKey)) {
      return of(this.cache.get(cacheKey));
    }

    return this.http.get<SeasonDetails>(`${this.apiUrl}/tv/${tvId}/season/${seasonNumber}`)
      .pipe(
        map(season => ({
          ...season,
          poster_url: this.buildImageUrl(season.poster_path),
          episodes: season.episodes?.map(episode => ({
            ...episode,
            still_url: this.buildImageUrl(episode.still_path)
          })) || []
        })),
        tap(season => this.cache.set(cacheKey, season)),
        catchError(error => {
          console.error('❌ Erreur détails saison:', error);
          throw error;
        })
      );
  }

  // ================================================================
  // GENRES
  // ================================================================

  getGenres(type: 'movie' | 'tv' = 'movie'): Observable<{ genres: Genre[] }> {
    const params = new HttpParams().set('type', type);

    return this.http.get<{ genres: Genre[] }>(`${this.apiUrl}/genres`, { params })
      .pipe(
        catchError(error => {
          console.error('❌ Erreur genres:', error);
          return of({ genres: [] });
        })
      );
  }

  discoverByGenre(genreId: number, type: 'movie' | 'tv' = 'movie', page: number = 1): Observable<TMDBResponse<TMDBContent>> {
    const params = new HttpParams()
      .set('type', type)
      .set('page', page.toString());

    return this.http.get<TMDBResponse<TMDBContent>>(`${this.apiUrl}/genres/${genreId}/discover`, { params })
      .pipe(
        map(response => this.enrichContentUrls(response)),
        catchError(error => {
          console.error('❌ Erreur découverte par genre:', error);
          return of({ page: 1, results: [], total_pages: 0, total_results: 0 });
        })
      );
  }

  // ================================================================
  // STREAMING
  // ================================================================

  getStreamUrl(type: 'movie' | 'tv', id: number, season?: number, episode?: number): Observable<StreamInfo> {
    let params = new HttpParams();
    
    if (season !== undefined) params = params.set('season', season.toString());
    if (episode !== undefined) params = params.set('episode', episode.toString());

    return this.http.get<StreamInfo>(`${this.apiUrl}/stream/${type}/${id}`, { params })
      .pipe(
        catchError(error => {
          console.error('❌ Erreur URL streaming:', error);
          throw error;
        })
      );
  }

  // ================================================================
  // MÉTHODES UTILITAIRES (comme Flutter)
  // ================================================================

  // Méthodes adaptées du Flutter pour l'interface web
  getTrendingMixed(): Observable<TMDBContent[]> {
    return this.getTrending('all', 'day', 1).pipe(
      map(response => response.results.slice(0, 20))
    );
  }

  getRecommendedMovies(): Observable<TMDBContent[]> {
    return forkJoin([
      this.getPopular('movie', 1),
      this.getTopRated('movie', 1)
    ]).pipe(
      map(([popular, topRated]) => {
        const combined = [...popular.results.slice(0, 10), ...topRated.results.slice(0, 10)];
        return this.shuffleArray(combined).slice(0, 20);
      })
    );
  }

  getNewSeries(): Observable<TMDBContent[]> {
    return this.getPopular('tv', 1).pipe(
      map(response => response.results.slice(0, 20))
    );
  }

  // Méthodes pour enrichir les URLs d'images (comme dans le backend)
  private enrichContentUrls(response: TMDBResponse<TMDBContent>): TMDBResponse<TMDBContent> {
    return {
      ...response,
      results: response.results.map(item => this.enrichSingleContent(item))
    };
  }

  private enrichSingleContent(content: TMDBContent): TMDBContent {
    return {
      ...content,
      poster_url: this.buildImageUrl(content.poster_path),
      backdrop_url: this.buildImageUrl(content.backdrop_path, 'w1280'),
      media_type: content.media_type || (content.title ? 'movie' : 'tv')
    };
  }

  private buildImageUrl(path: string | null, size: string = 'w500'): string | undefined {
    if (!path) return undefined;
    return `https://image.tmdb.org/t/p/${size}${path}`;
  }

  // Méthodes utilitaires
  getDisplayTitle(content: TMDBContent): string {
    return content.title || content.name || 'Titre inconnu';
  }

  getReleaseYear(content: TMDBContent): number | null {
    const date = content.release_date || content.first_air_date;
    return date ? new Date(date).getFullYear() : null;
  }

  getMediaType(content: TMDBContent): 'movie' | 'tv' {
    return content.media_type || (content.title ? 'movie' : 'tv');
  }

  isRecentContent(content: TMDBContent): boolean {
    const date = content.release_date || content.first_air_date;
    if (!date) return false;
    
    const releaseDate = new Date(date);
    const sixMonthsAgo = new Date();
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);
    
    return releaseDate > sixMonthsAgo;
  }

  private shuffleArray<T>(array: T[]): T[] {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  }

  // Effacer le cache
  clearCache(): void {
    this.cache.clear();
    console.log('🗑️ Cache content service effacé');
  }

  // Recharger tout le contenu
  refreshContent(): void {
    this.clearCache();
    this.loadInitialContent();
  }
}