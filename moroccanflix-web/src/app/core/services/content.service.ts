// src/app/core/services/content.service.ts
import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, BehaviorSubject, catchError, of, forkJoin } from 'rxjs';
import { map, tap } from 'rxjs/operators';
import { environment } from '../../../environments/environment';

// Interfaces TMDB (similaires au Flutter)
export interface TMDBContent {
  id: number;
  title?: string; // Pour les films
  name?: string; // Pour les séries
  overview: string;
  poster_path: string;
  backdrop_path: string;
  poster_url?: string;
  backdrop_url?: string;
  release_date?: string;
  first_air_date?: string;
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

@Injectable({
  providedIn: 'root'
})
export class ContentService {
  private readonly apiUrl = `${environment.apiUrl}/content`;
  
  // Cache pour optimiser les requêtes
  private cache = new Map<string, any>();
  
  // État global du contenu (comme Flutter)
  private trendingContent$ = new BehaviorSubject<TMDBContent[]>([]);
  private popularMovies$ = new BehaviorSubject<TMDBContent[]>([]);
  private popularSeries$ = new BehaviorSubject<TMDBContent[]>([]);
  private topRatedMovies$ = new BehaviorSubject<TMDBContent[]>([]);
  private upcomingMovies$ = new BehaviorSubject<TMDBContent[]>([]);

  // Observables publics
  public trendingContent = this.trendingContent$.asObservable();
  public popularMovies = this.popularMovies$.asObservable();
  public popularSeries = this.popularSeries$.asObservable();
  public topRatedMovies = this.topRatedMovies$.asObservable();
  public upcomingMovies = this.upcomingMovies$.asObservable();

  constructor(private http: HttpClient) {
    console.log('🎬 Content Service initialisé');
  }

  // ================================================================
  // MÉTHODES API PRINCIPALES (comme Flutter)
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
  // MÉTHODES ADAPTÉES POUR ANGULAR (comme Flutter)
  // ================================================================
  
  loadAllContent(): Observable<any> {
    return forkJoin({
      trending: this.getTrending('all', 'day'),
      popularMovies: this.getPopular('movie'),
      popularSeries: this.getPopular('tv'),
      topRated: this.getTopRated('movie'),
      upcoming: this.getUpcoming()
    }).pipe(
      tap(data => {
        this.trendingContent$.next(data.trending.results || []);
        this.popularMovies$.next(data.popularMovies.results || []);
        this.popularSeries$.next(data.popularSeries.results || []);
        this.topRatedMovies$.next(data.topRated.results || []);
        this.upcomingMovies$.next(data.upcoming.results || []);
      }),
      catchError(error => {
        console.error('❌ Erreur chargement contenu:', error);
        return of(null);
      })
    );
  }

  // Méthodes pour obtenir le contenu formaté
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

  getTrendingMixed(): Observable<TMDBContent[]> {
    return this.getTrending('all', 'day', 1).pipe(
      map(response => response.results.slice(0, 20))
    );
  }

  // ================================================================
  // MÉTHODES UTILITAIRES
  // ================================================================

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

  private shuffleArray<T>(array: T[]): T[] {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  }

  clearCache(): void {
    this.cache.clear();
  }

  refreshContent(): void {
    this.clearCache();
    this.loadAllContent().subscribe();
  }
}