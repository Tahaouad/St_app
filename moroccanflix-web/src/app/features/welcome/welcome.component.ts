// ================================================================
// REMPLACER ENTIÈREMENT src/app/features/welcome/welcome.component.ts
// ================================================================

import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-welcome',
  standalone: true,
  imports: [CommonModule], // ✅ CRUCIAL pour *ngFor
  template: `
    <div class="welcome-container">
      <!-- Background with overlay -->
      <div class="background-image"></div>
      <div class="overlay"></div>
      
      <!-- Content -->
      <div class="content animate-fade-in">
        <div class="container">
          <!-- Logo Section -->
          <div class="logo-section animate-slide-up">
            <h1 class="logo">MoroccanFlix</h1>
          </div>
          
          <!-- Title Section -->
          <div class="title-section animate-slide-up">
            <div class="exclusive-badge">EXCLUSIVE</div>
            <h2 class="main-title">DAREDEVIL: REBORN</h2>
            <p class="subtitle">
              Thousands of movies and series await you.<br>
              Start watching now.
            </p>
          </div>
          
          <!-- Features Section -->
          <div class="features-section animate-slide-up">
            <div class="feature-item" *ngFor="let feature of features">
              <div class="feature-icon">
                <i [class]="feature.icon"></i>
              </div>
              <div class="feature-content">
                <h3 class="feature-title">{{ feature.title }}</h3>
                <p class="feature-description">{{ feature.description }}</p>
              </div>
            </div>
          </div>
          
          <!-- Buttons Section -->
          <div class="buttons-section animate-slide-up">
            <button class="btn btn-primary btn-lg btn-full" (click)="navigateToLogin()">
              LOGIN
            </button>
            <button class="btn btn-secondary btn-lg btn-full" (click)="navigateToRegister()">
              CREATE ACCOUNT
            </button>
            <p class="terms-text">
              By continuing, you accept our terms of use
            </p>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .welcome-container {
      min-height: 100vh;
      position: relative;
      display: flex;
      align-items: center;
      overflow: hidden;
    }
    
    .background-image {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: url('/assets/images/welcome.jpg') center/cover;
      z-index: -2;
    }
    
    .overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(
        180deg,
        rgba(0, 0, 0, 0.7) 0%,
        rgba(0, 0, 0, 0.5) 30%,
        rgba(0, 0, 0, 0.7) 70%,
        rgba(0, 0, 0, 0.9) 100%
      );
      z-index: -1;
    }
    
    .content {
      width: 100%;
      padding: 2rem 0;
    }

    .container {
      max-width: 1440px;
      margin: 0 auto;
      padding: 0 1rem;
    }
    
    .logo-section {
      text-align: center;
      margin-bottom: 3rem;
      animation-delay: 0.2s;
    }
    
    .logo {
      color: #E50914;
      font-size: 2rem;
      font-weight: 800;
      letter-spacing: 2px;
      margin: 0;
    }
    
    .title-section {
      text-align: center;
      margin-bottom: 3rem;
      animation-delay: 0.4s;
    }
    
    .exclusive-badge {
      display: inline-block;
      background: #E50914;
      color: white;
      padding: 4px 12px;
      border-radius: 4px;
      font-size: 0.75rem;
      font-weight: 700;
      letter-spacing: 1.5px;
      margin-bottom: 1rem;
    }
    
    .main-title {
      font-size: 2.5rem;
      font-weight: 800;
      letter-spacing: 2px;
      margin: 0 0 1rem 0;
      color: #FFFFFF;
    }
    
    .subtitle {
      font-size: 1.125rem;
      color: rgba(255, 255, 255, 0.7);
      line-height: 1.5;
      margin: 0;
    }
    
    .features-section {
      margin-bottom: 3rem;
      animation-delay: 0.6s;
      max-width: 600px;
      margin-left: auto;
      margin-right: auto;
    }
    
    .feature-item {
      display: flex;
      align-items: center;
      background: rgba(0, 0, 0, 0.3);
      border: 1px solid rgba(255, 255, 255, 0.1);
      border-radius: 8px;
      padding: 1rem;
      margin-bottom: 1rem;
      backdrop-filter: blur(10px);
    }
    
    .feature-icon {
      width: 40px;
      height: 40px;
      background: rgba(229, 9, 20, 0.2);
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-right: 1rem;
      color: #E50914;
      font-size: 1.25rem;
    }
    
    .feature-content {
      flex: 1;
    }
    
    .feature-title {
      font-size: 0.938rem;
      font-weight: 700;
      color: #FFFFFF;
      margin: 0 0 2px 0;
    }
    
    .feature-description {
      font-size: 0.75rem;
      color: rgba(255, 255, 255, 0.7);
      margin: 0;
    }
    
    .buttons-section {
      animation-delay: 0.8s;
      max-width: 400px;
      margin: 0 auto;
    }

    .btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      padding: 0.5rem 1.5rem;
      border: none;
      border-radius: 8px;
      font-weight: 600;
      text-decoration: none;
      cursor: pointer;
      transition: all 0.2s ease;
      font-family: inherit;
      width: 100%;
      margin-bottom: 1rem;
    }

    .btn:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }

    .btn-primary {
      background: #E50914;
      color: #FFFFFF;
      box-shadow: 0 4px 20px rgba(229, 9, 20, 0.3);
    }

    .btn-primary:hover:not(:disabled) {
      background: #B8070F;
      transform: translateY(-1px);
    }

    .btn-secondary {
      background: transparent;
      color: #FFFFFF;
      border: 1px solid rgba(255, 255, 255, 0.5);
    }

    .btn-secondary:hover:not(:disabled) {
      border-color: #E50914;
      color: #E50914;
    }

    .btn-lg {
      padding: 1rem 2rem;
      font-size: 1.125rem;
    }

    .btn-full {
      width: 100%;
    }
    
    .terms-text {
      text-align: center;
      font-size: 0.75rem;
      color: rgba(255, 255, 255, 0.7);
      margin: 1.5rem 0 0 0;
    }

    /* Animations */
    .animate-fade-in {
      animation: fadeIn 0.6s ease-out;
    }

    .animate-slide-up {
      animation: slideInUp 0.6s ease-out;
    }

    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }

    @keyframes slideInUp {
      from {
        opacity: 0;
        transform: translateY(20px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }
    
    @media (min-width: 768px) {
      .container {
        padding: 0 2rem;
      }

      .main-title {
        font-size: 3rem;
      }
      
      .features-section {
        max-width: 600px;
        margin: 0 auto 3rem auto;
      }
      
      .buttons-section {
        max-width: 400px;
        margin: 0 auto;
      }
    }
    
    @media (max-width: 480px) {
      .main-title {
        font-size: 2rem;
      }
      
      .feature-item {
        padding: 0.5rem;
      }
      
      .feature-icon {
        width: 32px;
        height: 32px;
        font-size: 1rem;
      }
    }
  `]
})
export class WelcomeComponent implements OnInit {
  features = [
    {
      icon: 'fas fa-hd-video',
      title: 'Ultra HD & HDR',
      description: 'Enjoy exceptional image quality'
    },
    {
      icon: 'fas fa-download',
      title: 'Downloads',
      description: 'Watch offline wherever you are'
    },
    {
      icon: 'fas fa-devices',
      title: 'Multi-device',
      description: 'TV, smartphone, tablet, and computer'
    }
  ];

  constructor(
    private router: Router,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    // Si l'utilisateur est déjà connecté, rediriger vers la page d'accueil
    if (this.authService.isAuthenticated()) {
      this.router.navigate(['/home']);
    }
  }

  navigateToLogin(): void {
    this.router.navigate(['/auth/login']);
  }

  navigateToRegister(): void {
    this.router.navigate(['/auth/register']);
  }
}