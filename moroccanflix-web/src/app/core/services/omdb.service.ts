import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, of, catchError, map } from 'rxjs';
import { 
  TMDBContent, 
  ContentType,
  OMDBResponse, 
  OMDBSearchResponse, 
  ContentModelUtils 
} from '../models/content.model';

@Injectable({
  providedIn: 'root'
})
export class OMDBService {
  private readonly apiKey = 'YOUR_OMDB_API_KEY'; // Remplacez par votre vraie clé API
  private readonly baseUrl = 'https://www.omdbapi.com/';
  
  // Cache pour éviter les requêtes redondantes
  private cache = new Map<string, any>();

  constructor(private http: HttpClient) {
    console.log('🎬 OMDB Service initialisé');
  }

  /**
   * Rechercher du contenu par titre
   */
  searchByTitle(title: string, type?: ContentType, year?: number, page: number = 1): Observable<TMDBContent[]> {
    let params = new HttpParams()
      .set('apikey', this.apiKey)
      .set('s', title)
      .set('page', page.toString());

    if (type) {
      params = params.set('type', this.convertContentTypeToOMDB(type));
    }

    if (year) {
      params = params.set('y', year.toString());
    }

    const cacheKey = `search_${title}_${type}_${year}_${page}`;
    
    if (this.cache.has(cacheKey)) {
      return of(this.cache.get(cacheKey));
    }

    return this.http.get<OMDBSearchResponse>(this.baseUrl, { params }).pipe(
      map(response => {
        if (response.Response === 'True' && response.Search) {
          const results = response.Search.map(item => 
            ContentModelUtils.convertOMDBSearchToTMDB(item)
          );
          this.cache.set(cacheKey, results);
          return results;
        }
        return [];
      }),
      catchError(error => {
        console.error('❌ Erreur recherche OMDB:', error);
        return of([]);
      })
    );
  }

  /**
   * Obtenir les détails d'un contenu par ID IMDB
   */
  getByImdbId(imdbId: string): Observable<TMDBContent | null> {
    const params = new HttpParams()
      .set('apikey', this.apiKey)
      .set('i', imdbId)
      .set('plot', 'full');

    const cacheKey = `details_${imdbId}`;
    
    if (this.cache.has(cacheKey)) {
      return of(this.cache.get(cacheKey));
    }

    return this.http.get<OMDBResponse>(this.baseUrl, { params }).pipe(
      map(response => {
        if (response.Response === 'True') {
          const content = ContentModelUtils.convertOMDBToTMDB(response);
          this.cache.set(cacheKey, content);
          return content;
        }
        return null;
      }),
      catchError(error => {
        console.error('❌ Erreur détails OMDB:', error);
        return of(null);
      })
    );
  }

  /**
   * Obtenir les détails d'un contenu par titre
   */
  getByTitle(title: string, type?: ContentType, year?: number): Observable<TMDBContent | null> {
    let params = new HttpParams()
      .set('apikey', this.apiKey)
      .set('t', title)
      .set('plot', 'full');

    if (type) {
      params = params.set('type', this.convertContentTypeToOMDB(type));
    }

    if (year) {
      params = params.set('y', year.toString());
    }

    const cacheKey = `title_${title}_${type}_${year}`;
    
    if (this.cache.has(cacheKey)) {
      return of(this.cache.get(cacheKey));
    }

    return this.http.get<OMDBResponse>(this.baseUrl, { params }).pipe(
      map(response => {
        if (response.Response === 'True') {
          const content = ContentModelUtils.convertOMDBToTMDB(response);
          this.cache.set(cacheKey, content);
          return content;
        }
        return null;
      }),
      catchError(error => {
        console.error('❌ Erreur recherche par titre OMDB:', error);
        return of(null);
      })
    );
  }

  /**
   * Recherche rapide pour l'autocomplétion
   */
  quickSearch(query: string): Observable<TMDBContent[]> {
    if (!query.trim() || query.length < 2) {
      return of([]);
    }

    return this.searchByTitle(query, undefined, undefined, 1).pipe(
      map(results => results.slice(0, 5)) // Limiter à 5 résultats
    );
  }

  /**
   * Obtenir les films populaires (simulation avec OMDB)
   */
  getPopularMovies(): Observable<TMDBContent[]> {
    // OMDB n'a pas d'endpoint "populaire", donc on simule avec des recherches
    const popularTitles = [
      'Spider-Man', 'Batman', 'Avatar', 'Inception', 'The Matrix',
      'Iron Man', 'Thor', 'Captain America', 'Avengers', 'Deadpool'
    ];

    const searches = popularTitles.map(title => 
      this.searchByTitle(title, ContentType.MOVIE, undefined, 1)
    );

    return new Observable(observer => {
      Promise.all(searches.map(search => search.toPromise()))
        .then(results => {
          const allMovies = results.flat().filter(movie => movie);
          // Enlever les doublons basés sur l'ID
          const uniqueMovies = allMovies.filter((movie, index, self) => 
            index === self.findIndex(m => m.id === movie.id)
          );
          observer.next(uniqueMovies.slice(0, 20));
          observer.complete();
        })
        .catch(error => {
          console.error('❌ Erreur films populaires:', error);
          observer.next([]);
          observer.complete();
        });
    });
  }

  /**
   * Obtenir les séries populaires (simulation avec OMDB)
   */
  getPopularSeries(): Observable<TMDBContent[]> {
    const popularSeries = [
      'Game of Thrones', 'Breaking Bad', 'The Office', 'Friends', 'Stranger Things',
      'The Crown', 'Westworld', 'Lost', 'House of Cards', 'Narcos'
    ];

    const searches = popularSeries.map(title => 
      this.searchByTitle(title, ContentType.SERIES, undefined, 1)
    );

    return new Observable(observer => {
      Promise.all(searches.map(search => search.toPromise()))
        .then(results => {
          const allSeries = results.flat().filter(series => series);
          const uniqueSeries = allSeries.filter((series, index, self) => 
            index === self.findIndex(s => s.id === series.id)
          );
          observer.next(uniqueSeries.slice(0, 20));
          observer.complete();
        })
        .catch(error => {
          console.error('❌ Erreur séries populaires:', error);
          observer.next([]);
          observer.complete();
        });
    });
  }

  /**
   * Rechercher par genre (simulation)
   */
  searchByGenre(genre: string, type?: ContentType): Observable<TMDBContent[]> {
    // OMDB n'a pas de recherche par genre, donc on utilise des mots-clés associés
    const genreKeywords: { [key: string]: string[] } = {
      'Action': ['action', 'fight', 'war', 'adventure'],
      'Comedy': ['comedy', 'funny', 'humor', 'laugh'],
      'Drama': ['drama', 'emotional', 'life', 'family'],
      'Horror': ['horror', 'scary', 'ghost', 'zombie'],
      'Romance': ['love', 'romantic', 'romance', 'heart'],
      'Thriller': ['thriller', 'suspense', 'mystery', 'crime'],
      'Sci-Fi': ['science', 'space', 'future', 'alien'],
      'Fantasy': ['magic', 'fantasy', 'wizard', 'dragon']
    };

    const keywords = genreKeywords[genre] || [genre.toLowerCase()];
    const randomKeyword = keywords[Math.floor(Math.random() * keywords.length)];

    return this.searchByTitle(randomKeyword, type, undefined, 1);
  }

  /**
   * Obtenir des recommandations basées sur un contenu
   */
  getRecommendations(content: TMDBContent): Observable<TMDBContent[]> {
    // Utiliser le premier genre ou le titre pour trouver du contenu similaire
    const searchTerm = content.genres && content.genres.length > 0
      ? content.genres[0].toString()
      : content.title || content.name || '';

    return this.searchByTitle(searchTerm, content.type, undefined, 1).pipe(
      map(results => results.filter(item => item.id !== content.id).slice(0, 10))
    );
  }

  /**
   * Vérifier la validité de la clé API
   */
  validateApiKey(): Observable<boolean> {
    const params = new HttpParams()
      .set('apikey', this.apiKey)
      .set('t', 'test');

    return this.http.get<OMDBResponse>(this.baseUrl, { params }).pipe(
      map(response => !response.Error || response.Error !== 'Invalid API key!'),
      catchError(() => of(false))
    );
  }

  /**
   * Convertir les types de contenu vers le format OMDB
   */
  private convertContentTypeToOMDB(type: ContentType): string {
    switch (type) {
      case ContentType.MOVIE:
        return 'movie';
      case ContentType.SERIES:
        return 'series';
      case ContentType.EPISODE:
        return 'episode';
      default:
        return 'movie';
    }
  }

  /**
   * Vider le cache
   */
  clearCache(): void {
    this.cache.clear();
    console.log('🗑️ Cache OMDB effacé');
  }

  /**
   * Obtenir la taille du cache
   */
  getCacheSize(): number {
    return this.cache.size;
  }

  /**
   * Méthodes utilitaires pour l'interface
   */
  formatYear(content: TMDBContent): string {
    return content.year || 'Année inconnue';
  }

  formatRuntime(content: TMDBContent): string {
    return ContentModelUtils.formatRuntime(content.runtime || '');
  }

  formatRating(content: TMDBContent): string {
    const rating = ContentModelUtils.formatRating(content.imdbRating || '');
    return rating > 0 ? `${rating}/10` : 'Non noté';
  }

  getGenresList(content: TMDBContent): string {
    if (content.genres && content.genres.length > 0) {
      return content.genres.slice(0, 3).join(', ');
    }
    return content.genre || 'Genre inconnu';
  }

  isHighRated(content: TMDBContent): boolean {
    const rating = ContentModelUtils.formatRating(content.imdbRating || '');
    return rating >= 7.5;
  }

  isRecentContent(content: TMDBContent): boolean {
    if (!content.released && !content.year) return false;
    
    const year = content.year ? parseInt(content.year) : new Date(content.released!).getFullYear();
    const currentYear = new Date().getFullYear();
    
    return (currentYear - year) <= 3; // Contenu des 3 dernières années
  }
}