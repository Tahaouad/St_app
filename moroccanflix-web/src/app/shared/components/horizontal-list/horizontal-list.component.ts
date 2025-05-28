// ================================================================
// REMPLACER src/app/shared/components/horizontal-list/horizontal-list.component.ts
// ================================================================

import { Component, Input, Output, EventEmitter, OnInit, OnChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MovieCardComponent } from '../movie-card/movie-card.component';
import { TMDBContent } from '../../../core/models/content.model';

@Component({
  selector: 'app-horizontal-list',
  standalone: true,
  imports: [CommonModule, MovieCardComponent],
  template: `
    <div class="horizontal-list" *ngIf="items.length > 0">
      <!-- En-tête avec titre et bouton "Voir tout" -->
      <div class="list-header" *ngIf="title">
        <h2 class="list-title">
          <i [class]="icon" *ngIf="icon"></i>
          {{ title }}
          <span class="item-count" *ngIf="showCount">({{ items.length }})</span>
        </h2>
        <button 
          class="see-all-btn" 
          *ngIf="showSeeAll"
          (click)="onSeeAllClick()"
        >
          Tout voir
          <i class="fas fa-chevron-right"></i>
        </button>
      </div>

      <!-- Conteneur scrollable -->
      <div class="list-container">
        <div class="list-scroll" #scrollContainer>
          <div class="list-items">
            <div 
              class="list-item" 
              *ngFor="let item of items; let i = index; trackBy: trackByFn"
              [style.--item-index]="i"
            >
              <app-movie-card
                [content]="item"
                [showInfo]="showInfo"
                [showDescription]="showDescription"
                [isFavorite]="isFavoriteItem(item)"
                [watchProgress]="getWatchProgress(item)"
                [isNew]="isNewItem(item)"
                (play)="onPlay($event)"
                (favorite)="onFavorite($event)"
                (info)="onInfo($event)"
                (cardClick)="onCardClick($event)"
              ></app-movie-card>
            </div>
          </div>
        </div>

        <!-- Boutons de navigation -->
        <button 
          class="nav-btn nav-btn-left" 
          *ngIf="showNavButtons && canScrollLeft"
          (click)="scrollLeft()"
          [disabled]="isScrolling"
        >
          <i class="fas fa-chevron-left"></i>
        </button>
        
        <button 
          class="nav-btn nav-btn-right" 
          *ngIf="showNavButtons && canScrollRight"
          (click)="scrollRight()"
          [disabled]="isScrolling"
        >
          <i class="fas fa-chevron-right"></i>
        </button>
      </div>

      <!-- Indicateurs de scroll pour mobile -->
      <div class="scroll-indicators" *ngIf="showScrollIndicators && scrollPages.length > 1">
        <div 
          class="scroll-dot"
          *ngFor="let page of scrollPages; let i = index"
          [class.active]="i === currentPage"
          (click)="scrollToPage(i)"
        ></div>
      </div>

      <!-- État de chargement -->
      <div class="loading-state" *ngIf="isLoading">
        <div class="loading-item" *ngFor="let item of loadingItems"></div>
      </div>

      <!-- État vide -->
      <div class="empty-state" *ngIf="items.length === 0 && !isLoading">
        <i class="fas fa-film"></i>
        <p>Aucun contenu disponible</p>
      </div>
    </div>
  `,
  styles: [`
    .horizontal-list {
      margin-bottom: 2rem;
    }

    .list-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 1rem;
      padding: 0 1rem;
    }

    .list-title {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      color: #FFFFFF;
      font-size: 1.25rem;
      font-weight: 700;
      margin: 0;
    }

    .list-title i {
      color: #E50914;
      font-size: 1rem;
    }

    .item-count {
      font-size: 0.875rem;
      color: #B3B3B3;
      font-weight: 400;
      margin-left: 0.5rem;
    }

    .see-all-btn {
      display: flex;
      align-items: center;
      gap: 0.25rem;
      background: none;
      border: none;
      color: #E50914;
      cursor: pointer;
      font-weight: 500;
      transition: all 0.2s ease;
      padding: 0.5rem;
      border-radius: 4px;
    }

    .see-all-btn:hover {
      color: #B8070F;
      background: rgba(229, 9, 20, 0.1);
      transform: translateX(2px);
    }

    .see-all-btn i {
      font-size: 0.75rem;
      transition: transform 0.2s ease;
    }

    .see-all-btn:hover i {
      transform: translateX(2px);
    }

    .list-container {
      position: relative;
      overflow: hidden;
    }

    .list-scroll {
      overflow-x: auto;
      overflow-y: hidden;
      scrollbar-width: none;
      -ms-overflow-style: none;
      scroll-behavior: smooth;
      padding: 0 1rem;
    }

    .list-scroll::-webkit-scrollbar {
      display: none;
    }

    .list-items {
      display: flex;
      gap: 1rem;
      padding-bottom: 0.5rem;
    }

    .list-item {
      flex: 0 0 auto;
      width: 180px;
      animation: slideInRight 0.5s ease-out;
      animation-delay: calc(var(--item-index) * 0.05s);
      animation-fill-mode: both;
    }

    @media (max-width: 768px) {
      .list-item {
        width: 140px;
      }
    }

    @media (max-width: 480px) {
      .list-item {
        width: 120px;
      }
    }

    /* Boutons de navigation */
    .nav-btn {
      position: absolute;
      top: 50%;
      transform: translateY(-50%);
      background: rgba(0, 0, 0, 0.8);
      border: none;
      color: white;
      width: 48px;
      height: 48px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      z-index: 10;
      transition: all 0.2s ease;
      opacity: 0;
      visibility: hidden;
    }

    .list-container:hover .nav-btn {
      opacity: 1;
      visibility: visible;
    }

    .nav-btn:hover {
      background: rgba(229, 9, 20, 0.9);
      transform: translateY(-50%) scale(1.1);
    }

    .nav-btn:disabled {
      opacity: 0.3;
      cursor: not-allowed;
    }

    .nav-btn-left {
      left: 0.5rem;
    }

    .nav-btn-right {
      right: 0.5rem;
    }

    /* Indicateurs de scroll */
    .scroll-indicators {
      display: flex;
      justify-content: center;
      gap: 0.5rem;
      margin-top: 1rem;
      padding: 0 1rem;
    }

    .scroll-dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      background: rgba(255, 255, 255, 0.3);
      cursor: pointer;
      transition: all 0.2s ease;
    }

    .scroll-dot.active {
      background: #E50914;
      transform: scale(1.2);
    }

    .scroll-dot:hover {
      background: rgba(255, 255, 255, 0.6);
    }

    /* États de chargement et vide */
    .loading-state {
      display: flex;
      gap: 1rem;
      padding: 0 1rem;
    }

    .loading-item {
      flex: 0 0 auto;
      width: 180px;
      aspect-ratio: 2/3;
      background: linear-gradient(
        90deg,
        rgba(255, 255, 255, 0.1) 0%,
        rgba(255, 255, 255, 0.2) 50%,
        rgba(255, 255, 255, 0.1) 100%
      );
      background-size: 200% 100%;
      animation: shimmer 1.5s infinite;
      border-radius: 8px;
    }

    @keyframes shimmer {
      0% {
        background-position: -200% 0;
      }
      100% {
        background-position: 200% 0;
      }
    }

    .empty-state {
      text-align: center;
      padding: 2rem;
      color: #B3B3B3;
    }

    .empty-state i {
      font-size: 3rem;
      margin-bottom: 1rem;
      color: #666;
    }

    /* Masquer les indicateurs sur desktop */
    @media (min-width: 769px) {
      .scroll-indicators {
        display: none;
      }
    }

    /* Animations */
    @keyframes slideInRight {
      from {
        opacity: 0;
        transform: translateX(20px);
      }
      to {
        opacity: 1;
        transform: translateX(0);
      }
    }

    /* Responsive */
    @media (max-width: 768px) {
      .list-header {
        padding: 0 0.5rem;
      }

      .list-scroll {
        padding: 0 0.5rem;
      }

      .list-items {
        gap: 0.5rem;
      }

      .nav-btn {
        display: none; /* Masquer sur mobile */
      }

      .loading-item {
        width: 140px;
      }
    }

    @media (max-width: 480px) {
      .loading-item {
        width: 120px;
      }
    }
  `]
})
export class HorizontalListComponent implements OnInit, OnChanges {
  @Input() title: string = '';
  @Input() icon: string = '';
  @Input() items: TMDBContent[] = [];
  @Input() showInfo: boolean = false;
  @Input() showDescription: boolean = false;
  @Input() showSeeAll: boolean = true;
  @Input() showNavButtons: boolean = true;
  @Input() showScrollIndicators: boolean = false;
  @Input() showCount: boolean = false;
  @Input() isLoading: boolean = false;
  @Input() favoritesIds: number[] = [];
  @Input() watchProgressData: { [key: string]: number } = {};
  @Input() newItemsIds: number[] = [];

  @Output() play = new EventEmitter<TMDBContent>();
  @Output() favorite = new EventEmitter<{ content: TMDBContent, add: boolean }>();
  @Output() info = new EventEmitter<TMDBContent>();
  @Output() cardClick = new EventEmitter<TMDBContent>();
  @Output() seeAll = new EventEmitter<string>();

  canScrollLeft = false;
  canScrollRight = true;
  isScrolling = false;
  currentPage = 0;
  scrollPages: number[] = [];
  loadingItems = Array(6).fill(null); // 6 éléments de chargement

  ngOnInit(): void {
    setTimeout(() => {
      this.updateScrollState();
      this.calculateScrollPages();
    }, 100);
  }

  ngOnChanges(): void {
    if (this.items.length > 0) {
      setTimeout(() => {
        this.updateScrollState();
        this.calculateScrollPages();
      }, 100);
    }
  }

  trackByFn(index: number, item: TMDBContent): number {
    return item.id;
  }

  isFavoriteItem(item: TMDBContent): boolean {
    return this.favoritesIds.includes(item.id);
  }

  getWatchProgress(item: TMDBContent): number {
    const key = `${item.id}`;
    return this.watchProgressData[key] || 0;
  }

  isNewItem(item: TMDBContent): boolean {
    // Vérifier si l'item est dans la liste des nouveaux
    if (this.newItemsIds.includes(item.id)) {
      return true;
    }
    
    // Ou vérifier si c'est du contenu récent (moins de 3 mois)
    const releaseDate = item.release_date || item.first_air_date;
    if (releaseDate) {
      const threeMonthsAgo = new Date();
      threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3);
      return new Date(releaseDate) > threeMonthsAgo;
    }
    
    return false;
  }

  onPlay(content: TMDBContent): void {
    this.play.emit(content);
  }

  onFavorite(event: { content: TMDBContent, add: boolean }): void {
    this.favorite.emit(event);
  }

  onInfo(content: TMDBContent): void {
    this.info.emit(content);
  }

  onCardClick(content: TMDBContent): void {
    this.cardClick.emit(content);
  }

  onSeeAllClick(): void {
    this.seeAll.emit(this.title);
  }

  scrollLeft(): void {
    const container = document.querySelector('.list-scroll') as HTMLElement;
    if (container && !this.isScrolling) {
      this.isScrolling = true;
      const scrollAmount = container.clientWidth * 0.8;
      container.scrollBy({
        left: -scrollAmount,
        behavior: 'smooth'
      });
      
      setTimeout(() => {
        this.isScrolling = false;
        this.updateScrollState();
      }, 300);
    }
  }

  scrollRight(): void {
    const container = document.querySelector('.list-scroll') as HTMLElement;
    if (container && !this.isScrolling) {
      this.isScrolling = true;
      const scrollAmount = container.clientWidth * 0.8;
      container.scrollBy({
        left: scrollAmount,
        behavior: 'smooth'
      });
      
      setTimeout(() => {
        this.isScrolling = false;
        this.updateScrollState();
      }, 300);
    }
  }

  scrollToPage(pageIndex: number): void {
    const container = document.querySelector('.list-scroll') as HTMLElement;
    if (container && !this.isScrolling) {
      this.isScrolling = true;
      const scrollAmount = container.clientWidth * pageIndex;
      container.scrollTo({
        left: scrollAmount,
        behavior: 'smooth'
      });
      
      this.currentPage = pageIndex;
      
      setTimeout(() => {
        this.isScrolling = false;
        this.updateScrollState();
      }, 300);
    }
  }

  private updateScrollState(): void {
    const container = document.querySelector('.list-scroll') as HTMLElement;
    if (container) {
      this.canScrollLeft = container.scrollLeft > 0;
      this.canScrollRight = container.scrollLeft < (container.scrollWidth - container.clientWidth);
      
      // Calculer la page actuelle
      if (container.clientWidth > 0) {
        this.currentPage = Math.round(container.scrollLeft / container.clientWidth);
      }
    }
  }

  private calculateScrollPages(): void {
    const container = document.querySelector('.list-scroll') as HTMLElement;
    if (container && container.clientWidth > 0) {
      const totalWidth = container.scrollWidth;
      const visibleWidth = container.clientWidth;
      const pageCount = Math.ceil(totalWidth / visibleWidth);
      this.scrollPages = Array.from({ length: pageCount }, (_, i) => i);
    }
  }
}