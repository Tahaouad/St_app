// ================================================================
// REMPLACER ENTIÈREMENT src/app/features/auth/login/login.component.ts
// ================================================================

import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true, // ✅ STANDALONE = TRUE
  imports: [CommonModule, ReactiveFormsModule], // ✅ IMPORTS OBLIGATOIRES
  template: `
    <div class="auth-container">
      <div class="auth-card">
        <div class="auth-header">
          <button class="back-btn" (click)="goBack()">
            <i class="fas fa-arrow-left"></i>
          </button>
          <h1 class="auth-title">Welcome Back</h1>
          <p class="auth-subtitle">Login to your account</p>
        </div>

        <form [formGroup]="loginForm" (ngSubmit)="onSubmit()" class="auth-form">
          <!-- Email -->
          <div class="form-group">
            <label for="email" class="form-label">Email</label>
            <div class="input-wrapper">
              <i class="fas fa-envelope input-icon"></i>
              <input
                id="email"
                type="email"
                class="input"
                [class.error]="emailControl?.invalid && emailControl?.touched"
                formControlName="email"
                placeholder="Enter your email"
              />
            </div>
            <div class="error-message" *ngIf="emailControl?.invalid && emailControl?.touched">
              <span *ngIf="emailControl?.errors?.['required']">Email is required</span>
              <span *ngIf="emailControl?.errors?.['email']">Please enter a valid email</span>
            </div>
          </div>

          <!-- Password -->
          <div class="form-group">
            <label for="password" class="form-label">Password</label>
            <div class="input-wrapper">
              <i class="fas fa-lock input-icon"></i>
              <input
                id="password"
                [type]="showPassword ? 'text' : 'password'"
                class="input"
                [class.error]="passwordControl?.invalid && passwordControl?.touched"
                formControlName="password"
                placeholder="Enter your password"
              />
              <button type="button" class="password-toggle" (click)="togglePassword()">
                <i [class]="showPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
              </button>
            </div>
            <div class="error-message" *ngIf="passwordControl?.invalid && passwordControl?.touched">
              <span *ngIf="passwordControl?.errors?.['required']">Password is required</span>
            </div>
          </div>

          <!-- Error Message -->
          <div class="error-message" *ngIf="errorMessage">
            <i class="fas fa-exclamation-circle"></i>
            {{ errorMessage }}
          </div>

          <!-- Submit Button -->
          <button type="submit" class="btn btn-primary btn-lg btn-full" [disabled]="loginForm.invalid || isLoading">
            <span *ngIf="!isLoading">LOGIN</span>
            <div *ngIf="isLoading" class="loading-spinner">
              <i class="fas fa-spinner fa-spin"></i>
              <span>Logging in...</span>
            </div>
          </button>

          <!-- Register Link -->
          <div class="auth-link">
            <span class="link-text">Don't have an account?</span>
            <a (click)="navigateToRegister()" class="link">Register</a>
          </div>
        </form>
      </div>
    </div>
  `,
  styles: [`
    .auth-container {
      min-height: 100vh;
      background: linear-gradient(135deg, #141414 0%, #0a0a0a 100%);
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 1rem;
    }

    .auth-card {
      background: rgba(255, 255, 255, 0.05);
      backdrop-filter: blur(20px);
      border: 1px solid rgba(255, 255, 255, 0.1);
      border-radius: 16px;
      padding: 2rem;
      width: 100%;
      max-width: 400px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
    }

    .auth-header {
      text-align: center;
      margin-bottom: 2rem;
      position: relative;
    }

    .back-btn {
      position: absolute;
      left: 0;
      top: 0;
      background: none;
      border: none;
      color: #FFFFFF;
      font-size: 1.25rem;
      cursor: pointer;
      padding: 0.5rem;
      border-radius: 8px;
      transition: all 0.2s ease;
    }

    .back-btn:hover {
      background: rgba(255, 255, 255, 0.1);
      color: #E50914;
    }

    .auth-title {
      font-size: 2rem;
      font-weight: 800;
      color: #FFFFFF;
      margin: 0 0 0.5rem 0;
    }

    .auth-subtitle {
      color: rgba(255, 255, 255, 0.7);
      margin: 0;
    }

    .auth-form {
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
    }

    .form-group {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    .form-label {
      color: rgba(255, 255, 255, 0.7);
      font-weight: 500;
      font-size: 0.875rem;
    }

    .input-wrapper {
      position: relative;
      display: flex;
      align-items: center;
    }

    .input-icon {
      position: absolute;
      left: 1rem;
      color: #808080;
      font-size: 0.875rem;
      z-index: 1;
    }

    .input {
      width: 100%;
      padding: 1rem;
      padding-left: 2.5rem;
      background: rgba(255, 255, 255, 0.1);
      border: 1px solid rgba(255, 255, 255, 0.2);
      border-radius: 8px;
      color: #FFFFFF;
      font-family: inherit;
      transition: all 0.2s ease;
    }

    .input::placeholder {
      color: rgba(255, 255, 255, 0.7);
    }

    .input:focus {
      outline: none;
      border-color: #E50914;
      box-shadow: 0 0 0 2px rgba(229, 9, 20, 0.2);
    }

    .input.error {
      border-color: #F44336;
    }

    .password-toggle {
      position: absolute;
      right: 1rem;
      background: none;
      border: none;
      color: #808080;
      cursor: pointer;
      padding: 0.25rem;
      border-radius: 4px;
      transition: color 0.2s ease;
    }

    .password-toggle:hover {
      color: #E50914;
    }

    .error-message {
      color: #F44336;
      font-size: 0.875rem;
      display: flex;
      align-items: center;
      gap: 0.25rem;
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

    .btn-lg {
      padding: 1rem 2rem;
      font-size: 1.125rem;
    }

    .btn-full {
      width: 100%;
    }

    .loading-spinner {
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    .auth-link {
      text-align: center;
      margin-top: 1.5rem;
    }

    .link-text {
      color: rgba(255, 255, 255, 0.7);
      font-size: 0.875rem;
    }

    .link {
      color: #E50914;
      text-decoration: none;
      font-weight: 600;
      margin-left: 0.25rem;
      cursor: pointer;
      transition: color 0.2s ease;
    }

    .link:hover {
      color: #B8070F;
    }
  `]
})
export class LoginComponent implements OnInit {
  loginForm: FormGroup;
  isLoading = false;
  showPassword = false;
  errorMessage = '';

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private router: Router
  ) {
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6)]]
    });
  }

  ngOnInit(): void {
    if (this.authService.isAuthenticated()) {
      this.router.navigate(['/home']);
    }
  }

  get emailControl() {
    return this.loginForm.get('email');
  }

  get passwordControl() {
    return this.loginForm.get('password');
  }

  togglePassword(): void {
    this.showPassword = !this.showPassword;
  }

  onSubmit(): void {
    if (this.loginForm.valid && !this.isLoading) {
      this.isLoading = true;
      this.errorMessage = '';

      const { email, password } = this.loginForm.value;

      this.authService.login({ email, password }).subscribe({
        next: (response) => {
          this.isLoading = false;
          this.router.navigate(['/home']);
        },
        error: (error) => {
          this.isLoading = false;
          this.errorMessage = error.error?.message || 'Login failed. Please try again.';
        }
      });
    }
  }

  navigateToRegister(): void {
    this.router.navigate(['/auth/register']);
  }

  goBack(): void {
    this.router.navigate(['/welcome']);
  }
}