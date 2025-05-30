// src/app/features/home/home.component.ts
import { Component, OnInit, OnDestroy, HostListener } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { Subject, forkJoin } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import { AuthService, User } from '../../core/services/auth.service';
import { ContentService, TMDBContent } from '../../core/services/content.service';
import { HorizontalListComponent } from 'C:/Users/tahao/workspace/Full_project/moroccanflix-web/src/app/shared/components/horizontal-list/horizontal-list.component';


@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, HorizontalListComponent],
  templateUrl: './home.component.html',
  styleUrl: './home.component.css'
})
export class HomeComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();
  
  currentUser: User | null = null;
  isScrolled = false;
  sidebarOpen = false;
  showUserMenu = false;
  showSearch = false;
  isLoading = true;
  
  // Navigation
  activeSection: 'home' | 'movies' | 'series' | 'favorites' = 'home';
  selectedCategory: string = 'all';

  // Contenu
  featuredContent: TMDBContent | null = null;
  allMovies: TMDBContent[] = [];
  allSeries: TMDBContent[] = [];
  recommendedMovies: TMDBContent[] = [];
  trendingMovies: TMDBContent[] = [];
  newSeries: TMDBContent[] = [];
  newMovies: TMDBContent[] = [];
  
  popularMovies: TMDBContent[] = [];
  popularSeries: TMDBContent[] = [];
  favoriteItems: TMDBContent[] = [];

  // Données pour les composants
  favoritesIds: number[] = [];
  watchProgressData: { [key: string]: number } = {};
  newMoviesIds: number[] = [];
  newSeriesIds: number[] = [];

  constructor(
    private authService: AuthService,
    private contentService: ContentService,
    private router: Router
  ) {}

  ngOnInit(): void {
    console.log('🏠 Home Component initialisé');
    this.loadUserProfile();
    this.loadContent();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  @HostListener('window:scroll', ['$event'])
  onScroll(): void {
    this.isScrolled = window.scrollY > 100;
  }

  @HostListener('document:click', ['$event'])
  onDocumentClick(event: Event): void {
    const target = event.target as HTMLElement;
    if (!target.closest('.user-menu') && !target.closest('.user-dropdown')) {
      this.showUserMenu = false;
    }
  }

  private loadUserProfile(): void {
    this.authService.currentUser$
      .pipe(takeUntil(this.destroy$))
      .subscribe(user => {
        this.currentUser = user;
        if (!user) {
          this.authService.loadUserProfile().subscribe();
        }
      });
  }

  private loadContent(): void {
    this.isLoading = true;

    // Charger le contenu depuis les APIs TMDB
    forkJoin({
      trending: this.contentService.getTrendingMixed(),
      recommendedMovies: this.contentService.getRecommendedMovies(),
      newSeries: this.contentService.getNewSeries(),
      newMovies : this.contentService.getTrendingMixed(),
      popularMovies: this.contentService.getPopular('movie'),
      popularSeries: this.contentService.getPopular('tv')
    }).pipe(takeUntil(this.destroy$))
      .subscribe({
        next: ({ trending, recommendedMovies, newSeries,newMovies, popularMovies, popularSeries }) => {
          // Assigner le contenu
          this.trendingMovies = trending.filter(item => item.media_type === 'movie').slice(0, 10);
          this.recommendedMovies = recommendedMovies;
          this.newSeries = newSeries;
          this.newMovies = newMovies;
          this.popularMovies = popularMovies.results || [];
          this.popularSeries = popularSeries.results || [];
          
          // Combiner tout le contenu
          this.allMovies = [...this.popularMovies, ...this.trendingMovies, ...this.recommendedMovies, ...this.newMovies];
          this.allSeries = [...this.popularSeries, ...this.newSeries];
          
          // Contenu vedette (premier élément trending ou populaire)
          this.featuredContent = this.trendingMovies[0] || this.popularMovies[0] || this.allSeries[0];

          // IDs pour les badges "nouveau"
          this.newMoviesIds = this.trendingMovies.slice(0, 5).map(c => c.id);
          this.newSeriesIds = this.newSeries.slice(0, 5).map(c => c.id);

          this.isLoading = false;
          console.log('✅ Contenu chargé:', {
            trending: this.trendingMovies.length,
            movies: this.allMovies.length,
            series: this.allSeries.length,
            featured: this.featuredContent?.title || this.featuredContent?.name
          });
        },
        error: (err) => {
          console.error('❌ Erreur chargement contenu:', err);
          this.loadMockData();
          this.isLoading = false;
        }
      });
  }

  private loadMockData(): void {
    // Données d'exemple si l'API ne fonctionne pas
    this.featuredContent = {
      id: 1,
      title: "Daredevil: Reborn",
      overview: "Matt Murdock combat l'injustice le jour comme avocat et la nuit comme justicier masqué.",
      poster_url: "/assets/images/welcome.jpg",
      backdrop_url: "/assets/images/welcome.jpg",
      vote_average: 9.2,
      media_type: 'movie',
      poster_path: '',
      backdrop_path: '',
      vote_count: 1000,
      popularity: 100,
      genre_ids: [],
      adult: false,
      original_language: 'en',
      release_date: '2024-01-01'
    } as TMDBContent;
    
    this.allMovies = [];
    this.allSeries = [];
    this.trendingMovies = [];
    this.newSeries = [];
    this.popularMovies = [];
    this.popularSeries = [];
  }

  // ================================================================
  // MÉTHODES UTILITAIRES
  // ================================================================

  getDisplayTitle(content: TMDBContent): string {
    return this.contentService.getDisplayTitle(content);
  }

  getReleaseYear(content: TMDBContent): number | null {
    return this.contentService.getReleaseYear(content);
  }

  // ================================================================
  // ACTIONS DE NAVIGATION
  // ================================================================

  toggleSidebar(): void {
    this.sidebarOpen = !this.sidebarOpen;
  }

  toggleUserMenu(): void {
    this.showUserMenu = !this.showUserMenu;
  }

  toggleSearch(): void {
    this.showSearch = !this.showSearch;
  }

  setActiveSection(section: 'home' | 'movies' | 'series' | 'favorites'): void {
    this.activeSection = section;
    this.sidebarOpen = false;
  }

  selectCategory(category: string): void {
    this.selectedCategory = category;
  }

  // ================================================================
  // ACTIONS DE CONTENU
  // ================================================================

  playContent(content: TMDBContent): void {
    console.log('▶️ Lecture de:', this.getDisplayTitle(content));
    // TODO: Implémenter le lecteur vidéo
    alert(`Lecture de: ${this.getDisplayTitle(content)}`);
  }

  showInfo(content: TMDBContent): void {
    console.log('ℹ️ Infos sur:', this.getDisplayTitle(content));
    // TODO: Implémenter la page de détail
    alert(`Informations sur: ${this.getDisplayTitle(content)}`);
  }

  toggleFavorite(content: TMDBContent): void {
    const isFav = this.isFavorite(content);
    
    if (isFav) {
      // Retirer des favoris
      this.favoritesIds = this.favoritesIds.filter(id => id !== content.id);
      this.favoriteItems = this.favoriteItems.filter(item => item.id !== content.id);
      console.log('❤️ Retiré des favoris:', this.getDisplayTitle(content));
    } else {
      // Ajouter aux favoris
      this.favoritesIds.push(content.id);
      this.favoriteItems.push(content);
      console.log('💖 Ajouté aux favoris:', this.getDisplayTitle(content));
    }
  }

  toggleFavoriteFromList(event: { content: TMDBContent, add: boolean }): void {
    this.toggleFavorite(event.content);
  }

  isFavorite(content: TMDBContent): boolean {
    return this.favoritesIds.includes(content.id);
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/welcome']);
  }
}
