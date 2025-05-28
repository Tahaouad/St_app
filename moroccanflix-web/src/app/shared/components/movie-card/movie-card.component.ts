// ================================================================
// REMPLACER src/app/shared/components/movie-card/movie-card.component.ts
// ================================================================

import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TMDBContent } from '../../../core/services/content.service';

@Component({
  selector: 'app-movie-card',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="movie-card" [class.series]="isSeries" (click)="onCardClick()">
      <!-- Image du poster -->
      <div class="movie-poster">
        <img 
          [src]="posterUrl" 
          [alt]="title"
          (error)="onImageError($event)"
          [class.loaded]="imageLoaded"
          (load)="onImageLoad()"
        />
        
        <!-- Loading placeholder -->
        <div class="image-placeholder" *ngIf="!imageLoaded">
          <i class="fas fa-film"></i>
        </div>

        <!-- Overlay avec boutons -->
        <div class="movie-overlay">
          <button class="play-btn" (click)="onPlayClick($event)">
            <i class="fas fa-play"></i>
          </button>
          <div class="overlay-actions">
            <button 
              class="action-btn favorite-btn" 
              [class.active]="isFavorite"
              (click)="onFavoriteClick($event)"
              [title]="isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris'"
            >
              <i [class]="isFavorite ? 'fas fa-heart' : 'far fa-heart'"></i>
            </button>
            <button 
              class="action-btn info-btn" 
              (click)="onInfoClick($event)"
              title="Plus d'informations"
            >
              <i class="fas fa-info-circle"></i>
            </button>
          </div>
        </div>

        <!-- Badge nouveau -->
        <div class="badge new-badge" *ngIf="isNew">
          NOUVEAU
        </div>

        <!-- Badge type (film/série) -->
        <div class="badge type-badge" [class.series]="isSeries" [class.movie]="!isSeries">
          {{ isSeries ? 'SÉRIE' : 'FILM' }}
        </div>

        <!-- Note TMDB -->
        <div class="rating-badge" *ngIf="rating > 0">
          <i class="fas fa-star"></i>
          <span>{{ rating.toFixed(1) }}</span>
        </div>

        <!-- Barre de progression -->
        <div class="progress-bar" *ngIf="watchProgress > 0">
          <div class="progress-fill" [style.width.%]="watchProgress"></div>
        </div>
      </div>

      <!-- Informations du film/série -->
      <div class="movie-info" *ngIf="showInfo">
        <h3 class="movie-title">{{ title }}</h3>
        <div class="movie-meta">
          <span class="release-year" *ngIf="releaseYear">{{ releaseYear }}</span>
          <span class="popularity" *ngIf="content.popularity">
            <i class="fas fa-fire"></i>
            {{ formatPopularity(content.popularity) }}
          </span>
          <div class="rating" *ngIf="rating > 0">
            <i class="fas fa-star"></i>
            <span>{{ rating.toFixed(1) }}</span>
          </div>
        </div>
        <div class="genres" *ngIf="content.genres && content.genres.length > 0">
          <span class="genre-chip" *ngFor="let genre of content.genres.slice(0, 2)">
            {{ genre.name }}
          </span>
        </div>
        <p class="movie-description" *ngIf="showDescription && description">
          {{ truncateText(description, 120) }}
        </p>
      </div>
    </div>
  `,
  styles: [`
    .movie-card {
      position: relative;
      border-radius: 8px;
      overflow: hidden;
      cursor: pointer;
      transition: all 0.3s ease;
      background: rgba(255, 255, 255, 0.05);
      aspect-ratio: 2/3;
    }

    .movie-card:hover {
      transform: scale(1.05);
      z-index: 10;
      box-shadow: 0 8px 25px rgba(0, 0, 0, 0.6);
    }

    .movie-poster {
      position: relative;
      width: 100%;
      height: 100%;
      overflow: hidden;
    }

    .movie-poster img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      transition: all 0.3s ease;
      opacity: 0;
    }

    .movie-poster img.loaded {
      opacity: 1;
    }

    .image-placeholder {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 100%);
      color: #666;
      font-size: 2rem;
    }

    .movie-overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(
        180deg,
        rgba(0, 0, 0, 0.1) 0%,
        rgba(0, 0, 0, 0.3) 50%,
        rgba(0, 0, 0, 0.8) 100%
      );
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      opacity: 0;
      transition: all 0.3s ease;
    }

    .movie-card:hover .movie-overlay {
      opacity: 1;
    }

    .play-btn {
      background: #E50914;
      border: none;
      color: white;
      width: 48px;
      height: 48px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      box-shadow: 0 4px 20px rgba(229, 9, 20, 0.3);
      transition: all 0.2s ease;
      margin-bottom: 1rem;
    }

    .play-btn:hover {
      background: #B8070F;
      transform: scale(1.1);
    }

    .play-btn i {
      margin-left: 2px;
      font-size: 1.2rem;
    }

    .overlay-actions {
      display: flex;
      gap: 0.5rem;
    }

    .action-btn {
      background: rgba(0, 0, 0, 0.7);
      border: none;
      color: white;
      width: 36px;
      height: 36px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: all 0.2s ease;
    }

    .action-btn:hover {
      background: rgba(255, 255, 255, 0.2);
      transform: scale(1.1);
    }

    .favorite-btn.active {
      color: #E50914;
    }

    .badge {
      position: absolute;
      top: 8px;
      padding: 2px 6px;
      border-radius: 4px;
      font-size: 0.625rem;
      font-weight: 700;
      letter-spacing: 0.5px;
      text-transform: uppercase;
    }

    .new-badge {
      left: 8px;
      background: #E50914;
      color: white;
    }

    .type-badge {
      right: 8px;
      color: white;
    }

    .type-badge.series {
      background: #4CAF50;
    }

    .type-badge.movie {
      background: #2196F3;
    }

    .rating-badge {
      position: absolute;
      top: 8px;
      left: 50%;
      transform: translateX(-50%);
      background: rgba(0, 0, 0, 0.8);
      color: #FFA000;
      padding: 2px 6px;
      border-radius: 4px;
      font-size: 0.75rem;
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 2px;
    }

    .rating-badge i {
      font-size: 0.7rem;
    }

    .progress-bar {
      position: absolute;
      bottom: 0;
      left: 0;
      right: 0;
      height: 4px;
      background: rgba(255, 255, 255, 0.3);
    }

    .progress-fill {
      height: 100%;
      background: #E50914;
      transition: width 0.3s ease;
    }

    .movie-info {
      padding: 1rem;
      background: rgba(0, 0, 0, 0.8);
      color: white;
    }

    .movie-title {
      font-size: 1rem;
      font-weight: 600;
      margin: 0 0 0.5rem 0;
      color: white;
      line-height: 1.2;
    }

    .movie-meta {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      font-size: 0.75rem;
      color: #B3B3B3;
      margin-bottom: 0.5rem;
      flex-wrap: wrap;
    }

    .popularity {
      display: flex;
      align-items: center;
      gap: 0.25rem;
      color: #FF5722;
    }

    .popularity i {
      font-size: 0.7rem;
    }

    .rating {
      display: flex;
      align-items: center;
      gap: 0.25rem;
      color: #FFA000;
    }

    .rating i {
      font-size: 0.7rem;
    }

    .genres {
      display: flex;
      gap: 0.25rem;
      margin-bottom: 0.5rem;
      flex-wrap: wrap;
    }

    .genre-chip {
      background: rgba(229, 9, 20, 0.2);
      color: #E50914;
      padding: 2px 6px;
      border-radius: 3px;
      font-size: 0.625rem;
      font-weight: 500;
    }

    .movie-description {
      font-size: 0.75rem;
      color: #B3B3B3;
      line-height: 1.4;
      margin: 0;
    }

    /* Responsive */
    @media (max-width: 768px) {
      .movie-card {
        aspect-ratio: 2/3;
      }

      .movie-info {
        padding: 0.75rem;
      }

      .movie-title {
        font-size: 0.875rem;
      }

      .play-btn {
        width: 40px;
        height: 40px;
      }

      .action-btn {
        width: 32px;
        height: 32px;
      }

      .rating-badge {
        font-size: 0.7rem;
        padding: 1px 4px;
      }
    }

    /* Animation de chargement */
    @keyframes shimmer {
      0% {
        background-position: -200px 0;
      }
      100% {
        background-position: calc(200px + 100%) 0;
      }
    }

    .image-placeholder {
      background: linear-gradient(
        90deg,
        #1a1a1a 0px,
        #2a2a2a 40px,
        #1a1a1a 80px
      );
      background-size: 200px;
      animation: shimmer 1.5s infinite;
    }
  `]
})
export class MovieCardComponent {
  @Input() content!: TMDBContent;
  @Input() showInfo: boolean = false;
  @Input() showDescription: boolean = false;
  @Input() isFavorite: boolean = false;
  @Input() watchProgress: number = 0; // 0-100
  @Input() isNew: boolean = false;

  @Output() play = new EventEmitter<TMDBContent>();
  @Output() favorite = new EventEmitter<{ content: TMDBContent, add: boolean }>();
  @Output() info = new EventEmitter<TMDBContent>();
  @Output() cardClick = new EventEmitter<TMDBContent>();

  imageLoaded = false;

  get isSeries(): boolean {
    return this.content.media_type === 'tv' || !!this.content.name;
  }

  get title(): string {
    return this.content.title || this.content.name || 'Titre inconnu';
  }

  get description(): string {
    return this.content.overview || '';
  }

  get posterUrl(): string {
    if (this.content.poster_url) {
      return this.content.poster_url;
    }
    
    if (this.content.poster_path) {
      // TMDB image base URL
      return `https://image.tmdb.org/t/p/w500${this.content.poster_path}`;
    }
    
    // URL par défaut si pas de poster
    return `https://via.placeholder.com/300x450/1a1a1a/666666?text=${encodeURIComponent(this.title)}`;
  }

  get releaseYear(): number | null {
    const date = this.content.release_date || this.content.first_air_date;
    return date ? new Date(date).getFullYear() : null;
  }

  get rating(): number {
    return this.content.vote_average || 0;
  }

  onImageLoad(): void {
    this.imageLoaded = true;
  }

  onImageError(event: any): void {
    console.warn('Erreur de chargement d\'image pour:', this.title);
    // Remplacer par une image par défaut
    event.target.src = `https://via.placeholder.com/300x450/1a1a1a/666666?text=${encodeURIComponent(this.title)}`;
    this.imageLoaded = true;
  }

  onPlayClick(event: Event): void {
    event.stopPropagation();
    this.play.emit(this.content);
  }

  onFavoriteClick(event: Event): void {
    event.stopPropagation();
    this.favorite.emit({
      content: this.content,
      add: !this.isFavorite
    });
  }

  onInfoClick(event: Event): void {
    event.stopPropagation();
    this.info.emit(this.content);
  }

  onCardClick(): void {
    this.cardClick.emit(this.content);
  }

  formatPopularity(popularity: number): string {
    if (popularity >= 1000) {
      return `${(popularity / 1000).toFixed(1)}k`;
    }
    return Math.round(popularity).toString();
  }

  truncateText(text: string, maxLength: number): string {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength).trim() + '...';
  }
}