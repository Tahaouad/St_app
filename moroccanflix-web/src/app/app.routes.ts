import { Routes } from '@angular/router';
import { AuthGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  { path: '', redirectTo: '/welcome', pathMatch: 'full' },
  { path: 'welcome', loadComponent: () => import('./features/welcome/welcome.component').then(m => m.WelcomeComponent) },
  { path: 'auth', loadChildren: () => import('./features/auth/auth.routes').then(m => m.authRoutes) },
  { path: 'home', loadComponent: () => import('./features/home/home.component').then(m => m.HomeComponent), canActivate: [AuthGuard] },
  { path: '**', redirectTo: '/welcome' }
];
