// ================================================================
// CRÉER src/app/core/models/content.model.ts
// ================================================================

export interface Movie {
  id: number;
  title: string;
  description: string;
  duration: number;
  releaseYear: number;
  generalId: number;
  director: string;
  cast: string;
  ratingAVG: number;
  posterUrl: string;
  trailerUrl: string;
  createdAt: string;
  updatedAt: string;
}

export interface Series {
  id: number;
  title: string;
  description: string;
  createdAt: string;
  updatedAt: string;
  seasons?: Season[];
}

export interface Season {
  id: number;
  seriesId: number;
  seasonNumber: number;
  title: string;
  description: string;
  releaseDate: string;
  posterUrl: string;
  createdAt: string;
  updatedAt: string;
  episodes?: Episode[];
}

export interface Episode {
  id: number;
  seasonId: number;
  title: string;
  description: string;
  duration: number;
  episodeNumber: number;
  videoUrl: string;
  releaseDate: string;
  createdAt: string;
  updatedAt: string;
}

export interface Category {
  id: number;
  name: string;
  description: string;
  createdAt: string;
  updatedAt: string;
}

export interface Genre {
  id: number;
  name: string;
  description: string;
  createdAt: string;
  updatedAt: string;
}

export interface Favorite {
  id: number;
  userId: number;
  movieId?: number;
  seriesId?: number;
  createdAt: string;
  updatedAt: string;
  movie?: Movie;
  series?: Series;
}

export interface Rating {
  id: number;
  userId: number;
  movieId?: number;
  seriesId?: number;
  seasonId?: number;
  episodeId?: number;
  rating: number;
  comment: string;
  createdAt: string;
  updatedAt: string;
}

export interface WatchHistory {
  id: number;
  userId: number;
  movieId?: number;
  seriesId?: number;
  seasonId?: number;
  episodeId?: number;
  watchedAt: string;
  progress: number;
  createdAt: string;
  updatedAt: string;
  movie?: Movie;
  series?: Series;
  episode?: Episode;
}

export interface Media {
  id: number;
  url: string;
  type: string;
  movieId?: number;
  seriesId?: number;
  seasonId?: number;
  episodeId?: number;
  createdAt: string;
  updatedAt: string;
}

// Types pour les réponses API
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

export interface PaginatedResponse<T> {
  success: boolean;
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
  message?: string;
}