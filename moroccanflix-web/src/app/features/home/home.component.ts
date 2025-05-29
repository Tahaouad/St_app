// ================================================================
// REMPLACER src/app/features/home/home.component.ts
// ================================================================

import { Component, OnInit, OnDestroy, HostListener } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { Subject, forkJoin } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import { AuthService, User } from '../../core/services/auth.service';
import { ContentService, TMDBContent } from '../../core/services/content.service';
import { HorizontalListComponent } from '../../shared/components/horizontal-list/horizontal-list.component';
import { Movie, Series, Favorite, WatchHistory } from '../../core/models/content.model';
import { OMDBService } from '../../core/services/omdb.service';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, HorizontalListComponent],
  template: `
    <div class="home-container">
      <!-- Header avec AppBar flottant -->
      <header class="app-header" [class.scrolled]="isScrolled">
        <div class="container">
          <div class="header-content">
            <!-- Menu burger pour mobile -->
            <button class="menu-btn" (click)="toggleSidebar()">
              <i class="fas fa-bars"></i>
            </button>
            
            <!-- Logo -->
            <div class="logo" [class.hidden]="!isScrolled">
              <h1>MoroccanFlix</h1>
            </div>
            
            <!-- Navigation desktop -->
            <nav class="nav-desktop">
              <a href="#" class="nav-link" [class.active]="activeSection === 'home'" (click)="setActiveSection('home')">Accueil</a>
              <a href="#" class="nav-link" [class.active]="activeSection === 'series'" (click)="setActiveSection('series')">Séries</a>
              <a href="#" class="nav-link" [class.active]="activeSection === 'movies'" (click)="setActiveSection('movies')">Films</a>
              <a href="#" class="nav-link" [class.active]="activeSection === 'favorites'" (click)="setActiveSection('favorites')">Ma liste</a>
            </nav>
            
            <!-- Actions -->
            <div class="header-actions">
              <button class="search-btn" (click)="toggleSearch()">
                <i class="fas fa-search"></i>
              </button>
              <div class="user-menu" (click)="toggleUserMenu()">
                <img [src]="currentUser?.avatar" [alt]="currentUser?.name" class="user-avatar">
                <i class="fas fa-chevron-down"></i>
              </div>
              
              <!-- Dropdown menu utilisateur -->
              <div class="user-dropdown" [class.show]="showUserMenu">
                <div class="user-info">
                  <img [src]="currentUser?.avatar" [alt]="currentUser?.name">
                  <div>
                    <div class="user-name">{{ currentUser?.name }}</div>
                    <div class="user-email">{{ currentUser?.email }}</div>
                  </div>
                </div>
                <hr>
                <a href="#" class="dropdown-item">
                  <i class="fas fa-user"></i>
                  Mon profil
                </a>
                <a href="#" class="dropdown-item">
                  <i class="fas fa-cog"></i>
                  Paramètres
                </a>
                <a href="#" class="dropdown-item" (click)="setActiveSection('favorites')">
                  <i class="fas fa-heart"></i>
                  Ma liste
                </a>
                <hr>
                <button class="dropdown-item logout-btn" (click)="logout()">
                  <i class="fas fa-sign-out-alt"></i>
                  Se déconnecter
                </button>
              </div>
            </div>
          </div>
        </div>
      </header>

      <!-- Sidebar pour mobile -->
      <aside class="sidebar" [class.open]="sidebarOpen">
        <div class="sidebar-header">
          <h2>MoroccanFlix</h2>
          <button class="close-btn" (click)="toggleSidebar()">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <nav class="sidebar-nav">
          <a href="#" class="sidebar-link" [class.active]="activeSection === 'home'" (click)="setActiveSection('home')">
            <i class="fas fa-home"></i>
            Accueil
          </a>
          <a href="#" class="sidebar-link" [class.active]="activeSection === 'series'" (click)="setActiveSection('series')">
            <i class="fas fa-tv"></i>
            Séries
          </a>
          <a href="#" class="sidebar-link" [class.active]="activeSection === 'movies'" (click)="setActiveSection('movies')">
            <i class="fas fa-film"></i>
            Films
          </a>
          <a href="#" class="sidebar-link" [class.active]="activeSection === 'favorites'" (click)="setActiveSection('favorites')">
            <i class="fas fa-heart"></i>
            Ma liste
          </a>
          <a href="#" class="sidebar-link">
            <i class="fas fa-download"></i>
            Téléchargements
          </a>
          <a href="#" class="sidebar-link">
            <i class="fas fa-history"></i>
            Historique
          </a>
        </nav>
      </aside>

      <!-- Overlay pour sidebar mobile -->
      <div class="sidebar-overlay" [class.show]="sidebarOpen" (click)="toggleSidebar()"></div>

      <!-- Contenu principal -->
      <main class="main-content">
        <!-- Hero Section -->
        <section class="hero-section" *ngIf="activeSection === 'home' && featuredContent">
          <div class="hero-background">
            <img [src]="featuredContent.posterUrl || '/assets/images/welcome.jpg'" [alt]="featuredContent.title">
            <div class="hero-overlay"></div>
          </div>
          
          <div class="hero-content">
            <div class="container">
              <div class="hero-text">
                <div class="badge">{{ featuredContent.releaseYear ? 'FILM' : 'SÉRIE' }}</div>
                <h1 class="hero-title">{{ featuredContent.title }}</h1>
                <div class="hero-meta">
                  <div class="rating-chip" *ngIf="featuredContent.ratingAVG">
                    <i class="fas fa-star"></i>
                    <span>{{ featuredContent.ratingAVG.toFixed(1) }}</span>
                  </div>
                  <span class="meta-text" *ngIf="featuredContent.releaseYear">
                    {{ featuredContent.releaseYear }} • 4K Ultra HD
                  </span>
                </div>
                <p class="hero-description">
                  {{ featuredContent.description }}
                </p>
                <div class="hero-actions">
                  <button class="btn btn-primary btn-lg" (click)="playContent(featuredContent)">
                    <i class="fas fa-play"></i>
                    Lecture
                  </button>
                  <button class="btn btn-secondary" (click)="toggleFavorite(featuredContent)">
                    <i [class]="isFavorite(featuredContent) ? 'fas fa-check' : 'fas fa-plus'"></i>
                    {{ isFavorite(featuredContent) ? 'Dans ma liste' : 'Ma liste' }}
                  </button>
                  <button class="btn btn-ghost" (click)="showInfo(featuredContent)">
                    <i class="fas fa-info-circle"></i>
                    Infos
                  </button>
                </div>
              </div>
            </div>
          </div>
        </section>

        <!-- Categories -->
        <section class="categories-section" *ngIf="activeSection === 'home'">
          <div class="container">
            <div class="categories-scroll">
              <button 
                class="category-btn" 
                [class.active]="selectedCategory === 'all'"
                (click)="selectCategory('all')"
              >
                Pour vous
              </button>
              <button 
                class="category-btn"
                [class.active]="selectedCategory === 'series'"
                (click)="selectCategory('series')"
              >
                Séries
              </button>
              <button 
                class="category-btn"
                [class.active]="selectedCategory === 'movies'"
                (click)="selectCategory('movies')"
              >
                Films
              </button>
              <button 
                class="category-btn"
                [class.active]="selectedCategory === 'favorites'"
                (click)="selectCategory('favorites')"
              >
                Ma liste
              </button>
            </div>
          </div>
        </section>

        <!-- Loading State -->
        <div class="loading-container" *ngIf="isLoading">
          <div class="loading-spinner">
            <i class="fas fa-spinner fa-spin"></i>
            <p>Chargement du contenu...</p>
          </div>
        </div>

        <!-- Content Sections -->
        <section class="content-sections" *ngIf="!isLoading">
          <div class="container">
            
            <!-- Section Accueil -->
            <div *ngIf="activeSection === 'home'">
              <!-- Continuer à regarder -->
              <app-horizontal-list
                *ngIf="continueWatching.length > 0"
                title="Continuer à regarder"
                icon="fas fa-play-circle"
                [items]="continueWatching"
                [showInfo]="true"
                [favoritesIds]="favoritesIds"
                [watchProgressData]="watchProgressData"
                (play)="playContent($event)"
                (favorite)="toggleFavoriteFromList($event)"
                (info)="showInfo($event)"
                (cardClick)="showInfo($event)"
              ></app-horizontal-list>

              <!-- Films tendances -->
              <app-horizontal-list
                *ngIf="trendingMovies.length > 0"
                title="Tendances films"
                icon="fas fa-trending-up"
                [items]="trendingMovies"
                [favoritesIds]="favoritesIds"
                [newItemsIds]="newMoviesIds"
                (play)="playContent($event)"
                (favorite)="toggleFavoriteFromList($event)"
                (info)="showInfo($event)"
                (cardClick)="showInfo($event)"
              ></app-horizontal-list>

              <!-- Nouvelles séries -->
              <app-horizontal-list
                *ngIf="newSeries.length > 0"
                title="Nouvelles séries"
                icon="fas fa-sparkles"
                [items]="newSeries"
                [favoritesIds]="favoritesIds"
                [newItemsIds]="newSeriesIds"
                (play)="playContent($event)"
                (favorite)="toggleFavoriteFromList($event)"
                (info)="showInfo($event)"
                (cardClick)="showInfo($event)"
              ></app-horizontal-list>

              <!-- Recommandations -->
              <app-horizontal-list
                *ngIf="recommendedMovies.length > 0"
                title="Recommandé pour vous"
                icon="fas fa-thumbs-up"
                [items]="recommendedMovies"
                [favoritesIds]="favoritesIds"
                (play)="playContent($event)"
                (favorite)="toggleFavoriteFromList($event)"
                (info)="showInfo($event)"
                (cardClick)="showInfo($event)"
              ></app-horizontal-list>
            </div>

            <!-- Section Films -->
            <div *ngIf="activeSection === 'movies'">
              <app-horizontal-list
                *ngIf="allMovies.length > 0"
                title="Tous les films"
                icon="fas fa-film"
                [items]="allMovies"
                [favoritesIds]="favoritesIds"
                [watchProgressData]="watchProgressData"
                (play)="playContent($event)"
                (favorite)="toggleFavoriteFromList($event)"
                (info)="showInfo($event)"
                (cardClick)="showInfo($event)"
              ></app-horizontal-list>
            </div>

            <!-- Section Séries -->
            <div *ngIf="activeSection === 'series'">
              <app-horizontal-list
                *ngIf="allSeries.length > 0"
                title="Toutes les séries"
                icon="fas fa-tv"
                [items]="allSeries"
                [favoritesIds]="favoritesIds"
                [watchProgressData]="watchProgressData"
                (play)="playContent($event)"
                (favorite)="toggleFavoriteFromList($event)"
                (info)="showInfo($event)"
                (cardClick)="showInfo($event)"
              ></app-horizontal-list>
            </div>

            <!-- Section Favoris -->
            <div *ngIf="activeSection === 'favorites'">
              <app-horizontal-list
                *ngIf="favoriteItems.length > 0"
                title="Ma liste"
                icon="fas fa-heart"
                [items]="favoriteItems"
                [favoritesIds]="favoritesIds"
                [watchProgressData]="watchProgressData"
                [showSeeAll]="false"
                (play)="playContent($event)"
                (favorite)="toggleFavoriteFromList($event)"
                (info)="showInfo($event)"
                (cardClick)="showInfo($event)"
              ></app-horizontal-list>

              <div class="empty-state" *ngIf="favoriteItems.length === 0">
                <i class="fas fa-heart"></i>
                <h3>Votre liste est vide</h3>
                <p>Ajoutez des films et séries à votre liste pour les retrouver facilement</p>
                <button class="btn btn-primary" (click)="setActiveSection('home')">
                  Découvrir du contenu
                </button>
              </div>
            </div>

          </div>
        </section>
      </main>
    </div>
  `,
  styles: [`
    /* Reprise des styles du composant précédent + nouveaux styles */
    .home-container {
      min-height: 100vh;
      background: var(--background);
    }

    /* Header styles (identiques au précédent) */
    .app-header {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      z-index: 1000;
      background: transparent;
      transition: all 0.3s ease;
      padding: var(--spacing-md) 0;
    }

    .app-header.scrolled {
      background: rgba(20, 20, 20, 0.95);
      backdrop-filter: blur(20px);
      box-shadow: var(--shadow-header);
      padding: var(--spacing-sm) 0;
    }

    .header-content {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: var(--spacing-lg);
    }

    .menu-btn {
      display: none;
      background: none;
      border: none;
      color: var(--text-primary);
      font-size: 1.25rem;
      cursor: pointer;
      padding: var(--spacing-sm);
      border-radius: var(--radius-md);
      transition: all 0.2s ease;
    }

    .menu-btn:hover {
      background: rgba(255, 255, 255, 0.1);
      color: var(--primary);
    }

    @media (max-width: 768px) {
      .menu-btn {
        display: block;
      }
    }

    .logo {
      opacity: 0;
      transform: translateY(-10px);
      transition: all 0.3s ease;
    }

    .logo:not(.hidden) {
      opacity: 1;
      transform: translateY(0);
    }

    .logo h1 {
      color: var(--primary);
      font-size: 1.5rem;
      font-weight: 800;
      letter-spacing: 1px;
      margin: 0;
    }

    .nav-desktop {
      display: flex;
      gap: var(--spacing-lg);
    }

    @media (max-width: 768px) {
      .nav-desktop {
        display: none;
      }
    }

    .nav-link {
      color: var(--text-secondary);
      text-decoration: none;
      font-weight: 500;
      transition: color 0.2s ease;
      position: relative;
    }

    .nav-link:hover {
      color: var(--text-primary);
    }

    .nav-link.active {
      color: var(--text-primary);
    }

    .nav-link.active::after {
      content: '';
      position: absolute;
      bottom: -8px;
      left: 0;
      right: 0;
      height: 2px;
      background: var(--primary);
      border-radius: 1px;
    }

    .header-actions {
      display: flex;
      align-items: center;
      gap: var(--spacing-md);
      position: relative;
    }

    .search-btn {
      background: none;
      border: none;
      color: var(--text-primary);
      font-size: 1.125rem;
      cursor: pointer;
      padding: var(--spacing-sm);
      border-radius: var(--radius-md);
      transition: all 0.2s ease;
    }

    .search-btn:hover {
      background: rgba(255, 255, 255, 0.1);
      color: var(--primary);
    }

    .user-menu {
      display: flex;
      align-items: center;
      gap: var(--spacing-xs);
      cursor: pointer;
      padding: var(--spacing-xs);
      border-radius: var(--radius-md);
      transition: all 0.2s ease;
    }

    .user-menu:hover {
      background: rgba(255, 255, 255, 0.1);
    }

    .user-avatar {
      width: 32px;
      height: 32px;
      border-radius: 50%;
      border: 2px solid var(--primary);
      object-fit: cover;
    }

    .user-dropdown {
      position: absolute;
      top: 100%;
      right: 0;
      background: rgba(20, 20, 20, 0.95);
      backdrop-filter: blur(20px);
      border: 1px solid rgba(255, 255, 255, 0.1);
      border-radius: var(--radius-lg);
      min-width: 280px;
      box-shadow: var(--shadow-card);
      opacity: 0;
      visibility: hidden;
      transform: translateY(-10px);
      transition: all 0.3s ease;
      margin-top: var(--spacing-sm);
    }

    .user-dropdown.show {
      opacity: 1;
      visibility: visible;
      transform: translateY(0);
    }

    .user-info {
      display: flex;
      align-items: center;
      gap: var(--spacing-md);
      padding: var(--spacing-lg);
    }

    .user-info img {
      width: 48px;
      height: 48px;
      border-radius: 50%;
      border: 2px solid var(--primary);
      object-fit: cover;
    }

    .user-name {
      color: var(--text-primary);
      font-weight: 600;
      margin-bottom: 2px;
    }

    .user-email {
      color: var(--text-secondary);
      font-size: 0.875rem;
    }

    .dropdown-item {
      display: flex;
      align-items: center;
      gap: var(--spacing-md);
      padding: var(--spacing-md) var(--spacing-lg);
      color: var(--text-secondary);
      text-decoration: none;
      transition: all 0.2s ease;
      border: none;
      background: none;
      width: 100%;
      text-align: left;
      cursor: pointer;
    }

    .dropdown-item:hover {
      background: rgba(255, 255, 255, 0.1);
      color: var(--text-primary);
    }

    .dropdown-item i {
      width: 16px;
      font-size: 0.875rem;
    }

    .logout-btn {
      color: var(--error);
    }

    .logout-btn:hover {
      background: rgba(244, 67, 54, 0.1);
      color: var(--error);
    }

    /* Sidebar styles */
    .sidebar {
      position: fixed;
      top: 0;
      left: -300px;
      width: 300px;
      height: 100vh;
      background: rgba(20, 20, 20, 0.98);
      backdrop-filter: blur(20px);
      border-right: 1px solid rgba(255, 255, 255, 0.1);
      z-index: 1001;
      transition: left 0.3s ease;
      overflow-y: auto;
    }

    .sidebar.open {
      left: 0;
    }

    .sidebar-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: var(--spacing-lg);
      border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    }

    .sidebar-header h2 {
      color: var(--primary);
      font-size: 1.5rem;
      font-weight: 800;
      margin: 0;
    }

    .close-btn {
      background: none;
      border: none;
      color: var(--text-primary);
      font-size: 1.25rem;
      cursor: pointer;
      padding: var(--spacing-sm);
      border-radius: var(--radius-md);
      transition: all 0.2s ease;
    }

    .close-btn:hover {
      background: rgba(255, 255, 255, 0.1);
      color: var(--primary);
    }

    .sidebar-nav {
      padding: var(--spacing-lg) 0;
    }

    .sidebar-link {
      display: flex;
      align-items: center;
      gap: var(--spacing-md);
      padding: var(--spacing-md) var(--spacing-lg);
      color: var(--text-secondary);
      text-decoration: none;
      transition: all 0.2s ease;
    }

    .sidebar-link:hover {
      background: rgba(255, 255, 255, 0.1);
      color: var(--text-primary);
    }

    .sidebar-link.active {
      background: rgba(229, 9, 20, 0.1);
      color: var(--primary);
      border-right: 3px solid var(--primary);
    }

    .sidebar-link i {
      width: 20px;
      font-size: 1rem;
    }

    .sidebar-overlay {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.5);
      z-index: 1000;
      opacity: 0;
      visibility: hidden;
      transition: all 0.3s ease;
    }

    .sidebar-overlay.show {
      opacity: 1;
      visibility: visible;
    }

    /* Main Content */
    .main-content {
      padding-top: 80px;
    }

    /* Hero Section */
    .hero-section {
      position: relative;
      height: 70vh;
      min-height: 500px;
      display: flex;
      align-items: flex-end;
      overflow: hidden;
    }

    .hero-background {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      z-index: -2;
    }

    .hero-background img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .hero-overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(
        180deg,
        rgba(0, 0, 0, 0.1) 0%,
        rgba(0, 0, 0, 0.3) 30%,
        rgba(0, 0, 0, 0.7) 50%,
        rgba(0, 0, 0, 0.9) 80%,
        var(--background) 100%
      );
      z-index: -1;
    }

    .hero-content {
      width: 100%;
      padding-bottom: var(--spacing-2xl);
    }

    .hero-text {
      max-width: 600px;
    }

    .badge {
      display: inline-block;
      background: var(--primary);
      color: white;
      padding: 4px 12px;
      border-radius: var(--radius-sm);
      font-size: 0.75rem;
      font-weight: 700;
      letter-spacing: 1px;
      margin-bottom: var(--spacing-md);
    }

    .hero-title {
      font-size: clamp(2rem, 5vw, 3rem);
      font-weight: 800;
      letter-spacing: 2px;
      margin: 0 0 var(--spacing-md) 0;
      color: var(--text-primary);
    }

    .hero-meta {
      display: flex;
      align-items: center;
      gap: var(--spacing-md);
      margin-bottom: var(--spacing-md);
    }

    .rating-chip {
      display: flex;
      align-items: center;
      gap: 4px;
      background: #FFA000;
      color: #000;
      padding: 4px 8px;
      border-radius: var(--radius-sm);
      font-weight: 700;
      font-size: 0.875rem;
    }

    .meta-text {
      color: var(--text-secondary);
      font-size: 0.875rem;
    }

    .hero-description {
      color: var(--text-secondary);
      line-height: 1.6;
      margin-bottom: var(--spacing-xl);
      max-width: 500px;
    }

    .hero-actions {
      display: flex;
      align-items: center;
      gap: var(--spacing-md);
      flex-wrap: wrap;
    }

    /* Categories */
    .categories-section {
      padding: var(--spacing-lg) 0;
      border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    }

    .categories-scroll {
      display: flex;
      gap: var(--spacing-md);
      overflow-x: auto;
      padding-bottom: var(--spacing-sm);
    }

    .categories-scroll::-webkit-scrollbar {
      display: none;
    }

    .category-btn {
      background: transparent;
      border: 1px solid rgba(255, 255, 255, 0.3);
      color: var(--text-secondary);
      padding: var(--spacing-sm) var(--spacing-lg);
      border-radius: 20px;
      cursor: pointer;
      transition: all 0.2s ease;
      white-space: nowrap;
      font-weight: 500;
    }

    .category-btn:hover {
      border-color: var(--primary);
      color: var(--primary);
    }

    .category-btn.active {
      background: rgba(229, 9, 20, 0.2);
      border-color: var(--primary);
      color: var(--primary);
    }

    /* Content Sections */
    .content-sections {
      padding: var(--spacing-2xl) 0;
    }

    /* Loading State */
    .loading-container {
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 300px;
    }

    .loading-spinner {
      text-align: center;
      color: var(--text-secondary);
    }

    .loading-spinner i {
      font-size: 2rem;
      color: var(--primary);
      margin-bottom: var(--spacing-md);
    }

    /* Empty State */
    .empty-state {
      text-align: center;
      padding: var(--spacing-2xl);
      color: var(--text-secondary);
    }

    .empty-state i {
      font-size: 4rem;
      color: var(--primary);
      margin-bottom: var(--spacing-lg);
    }

    .empty-state h3 {
      color: var(--text-primary);
      font-size: 1.5rem;
      margin-bottom: var(--spacing-md);
    }

    .empty-state p {
      margin-bottom: var(--spacing-xl);
      max-width: 400px;
      margin-left: auto;
      margin-right: auto;
    }

    /* Responsive */
    @media (max-width: 768px) {
      .main-content {
        padding-top: 70px;
      }

      .hero-section {
        height: 60vh;
        min-height: 400px;
      }

      .hero-actions .btn {
        padding: var(--spacing-sm) var(--spacing-md);
        font-size: 0.875rem;
      }
    }

    /* Animations */
    .animate-fade-in {
      animation: fadeIn 0.6s ease-out;
    }

    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }
  `]
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

  // Données pour les composants
  favoritesIds: number[] = [];
  watchProgressData: { [key: string]: number } = {};
  newMoviesIds: number[] = [];
  newSeriesIds: number[] = [];

  constructor(
    private authService: AuthService,
    private contentService: ContentService,
    private omdbService: OMDBService, // <-- Ajouter ici
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

  // Combine TMDB + OMDB en parallèle
  forkJoin({
    tmdbMovies: this.contentService.getRecommendedMovies(),
    tmdbSeries: this.contentService.getNewSeries(),
    omdbMovies: this.omdbService.getPopularMovies(),
    omdbSeries: this.omdbService.getPopularSeries()
  }).pipe(takeUntil(this.destroy$))
    .subscribe({
      next: ({ tmdbMovies, tmdbSeries, omdbMovies, omdbSeries }) => {
        // Fusionner et dédupliquer (exemple simple, à affiner)
        const allMovies = [...tmdbMovies, ...omdbMovies];
        const allSeries = [...tmdbSeries, ...omdbSeries];

        this.allMovies = this.removeDuplicates(allMovies);
        this.allSeries = this.removeDuplicates(allSeries);

        this.trendingMovies = this.allMovies.slice(0, 10);
        this.newSeries = this.allSeries.slice(0, 10);
        this.recommendedMovies = this.shuffleArray(this.allMovies).slice(0, 10);
        this.featuredContent = this.trendingMovies[0] || this.allMovies[0] || this.allSeries[0];

        this.newMoviesIds = this.allMovies.slice(0, 5).map(c => c.id);
        this.newSeriesIds = this.allSeries.slice(0, 5).map(c => c.id);

        this.isLoading = false;
      },
      error: (err) => {
        console.error('❌ Erreur chargement contenu mixte TMDB/OMDB', err);
        this.loadMockData();
        this.isLoading = false;
      }
    });
}
private removeDuplicates(contents: TMDBContent[]): TMDBContent[] {
  const seen = new Set<number>();
  return contents.filter(content => {
    if (seen.has(content.id)) return false;
    seen.add(content.id);
    return true;
  });
}



  private processFavorites(favorites: Favorite[]): void {
    this.favoritesIds = [];
    this.favoriteItems = [];
    
    favorites.forEach(fav => {
      if (fav.movie) {
        this.favoritesIds.push(fav.movie.id);
        this.favoriteItems.push(fav.movie);
      }
      if (fav.series) {
        this.favoritesIds.push(fav.series.id);
        this.favoriteItems.push(fav.series);
      }
    });
  }

  private processWatchHistory(history: WatchHistory[]): void {
    this.watchProgressData = {};
    this.continueWatching = [];
    
    history.forEach(item => {
      if (item.progress > 0 && item.progress < 90) { // Pas terminé
        const key = `${item.movieId || item.seriesId}`;
        this.watchProgressData[key] = item.progress;
        
        if (item.movie) {
          this.continueWatching.push(item.movie);
        }
        if (item.series) {
          this.continueWatching.push(item.series);
        }
      }
    });
  }

  private loadMockData(): void {
    // Données d'exemple si l'API ne fonctionne pas
    this.allMovies = [];
    this.allSeries = [];
    this.featuredContent = {
      id: 1,
      title: "Daredevil: Reborn",
      description: "Matt Murdock combat l'injustice le jour comme avocat et la nuit comme justicier masqué.",
      posterUrl: "/assets/images/welcome.jpg",
      ratingAVG: 9.2
    } as Movie;
  }

  // Actions de navigation
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

  // Actions de contenu
  playContent(content: Movie | Series): void {
    console.log('▶️ Lecture de:', content.title);
    // TODO: Implémenter le lecteur vidéo
  }

  showInfo(content: Movie | Series): void {
    console.log('ℹ️ Infos sur:', content.title);
    // TODO: Implémenter la page de détail
  }

  toggleFavorite(content: Movie | Series): void {
    const isFav = this.isFavorite(content);
    const movieId = 'duration' in content ? content.id : undefined;
    const seriesId = 'duration' in content ? undefined : content.id;
    
    if (isFav) {
      // Retirer des favoris
      const favoriteItem = this.favoriteItems.find(item => item.id === content.id);
      if (favoriteItem) {
        // TODO: Appeler l'API pour supprimer
        this.favoritesIds = this.favoritesIds.filter(id => id !== content.id);
        this.favoriteItems = this.favoriteItems.filter(item => item.id !== content.id);
      }
    } else {
      // Ajouter aux favoris
      this.contentService.addToFavorites(movieId, seriesId).subscribe({
        next: (response) => {
          if (response.success) {
            this.favoritesIds.push(content.id);
            this.favoriteItems.push(content);
          }
        },
        error: (error) => {
          console.error('❌ Erreur ajout favori:', error);
        }
      });
    }
  }

  toggleFavoriteFromList(event: { content: Movie | Series, add: boolean }): void {
    this.toggleFavorite(event.content);
  }

  isFavorite(content: Movie | Series): boolean {
    return this.favoritesIds.includes(content.id);
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/welcome']);
  }
}