// ================================================================
// REMPLACER ENTIÈREMENT src/app/features/auth/register/register.component.ts
// ================================================================

import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-register',
  standalone: true, // ✅ STANDALONE = TRUE
  imports: [CommonModule, ReactiveFormsModule], // ✅ IMPORTS OBLIGATOIRES
  template: `
    <div class="auth-container">
      <div class="auth-card">
        <div class="auth-header">
          <button class="back-btn" (click)="goBack()">
            <i class="fas fa-arrow-left"></i>
          </button>
          <h1 class="auth-title">Create Account</h1>
          <p class="auth-subtitle">Register to get started</p>
        </div>

        <form [formGroup]="registerForm" (ngSubmit)="onSubmit()" class="auth-form">
          <!-- Avatar Selection -->
          <div class="form-group">
            <label class="form-label">Choose Your Avatar</label>
            <div class="avatar-selection">
              <div
                *ngFor="let avatar of avatars; let i = index"
                class="avatar-option"
                [class.selected]="selectedAvatarIndex === i"
                (click)="selectAvatar(i)"
              >
                <img [src]="avatar" [alt]="'Avatar ' + (i + 1)" />
              </div>
            </div>
            <div class="error-message" *ngIf="!selectedAvatar && isSubmitted">
              Please select an avatar
            </div>
          </div>

          <!-- Username -->
          <div class="form-group">
            <label for="username" class="form-label">Username</label>
            <div class="input-wrapper">
              <i class="fas fa-user input-icon"></i>
              <input
                id="username"
                type="text"
                class="input"
                [class.error]="usernameControl?.invalid && usernameControl?.touched"
                formControlName="username"
                placeholder="Enter your username"
              />
            </div>
            <div class="error-message" *ngIf="usernameControl?.invalid && usernameControl?.touched">
              <span *ngIf="usernameControl?.errors?.['required']">Username is required</span>
              <span *ngIf="usernameControl?.errors?.['minlength']">Username must be at least 3 characters</span>
            </div>
          </div>

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
              <span *ngIf="passwordControl?.errors?.['minlength']">Password must be at least 6 characters</span>
            </div>
          </div>

          <!-- Confirm Password -->
          <div class="form-group">
            <label for="confirmPassword" class="form-label">Confirm Password</label>
            <div class="input-wrapper">
              <i class="fas fa-lock input-icon"></i>
              <input
                id="confirmPassword"
                [type]="showConfirmPassword ? 'text' : 'password'"
                class="input"
                [class.error]="confirmPasswordControl?.invalid && confirmPasswordControl?.touched"
                formControlName="confirmPassword"
                placeholder="Confirm your password"
              />
              <button type="button" class="password-toggle" (click)="toggleConfirmPassword()">
                <i [class]="showConfirmPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
              </button>
            </div>
            <div class="error-message" *ngIf="confirmPasswordControl?.invalid && confirmPasswordControl?.touched">
              <span *ngIf="confirmPasswordControl?.errors?.['required']">Please confirm your password</span>
              <span *ngIf="confirmPasswordControl?.errors?.['passwordMismatch']">Passwords do not match</span>
            </div>
          </div>

          <!-- Error Message -->
          <div class="error-message" *ngIf="errorMessage">
            <i class="fas fa-exclamation-circle"></i>
            {{ errorMessage }}
          </div>

          <!-- Submit Button -->
          <button type="submit" class="btn btn-primary btn-lg btn-full" [disabled]="isLoading">
            <span *ngIf="!isLoading">REGISTER</span>
            <div *ngIf="isLoading" class="loading-spinner">
              <i class="fas fa-spinner fa-spin"></i>
              <span>Creating account...</span>
            </div>
          </button>

          <!-- Login Link -->
          <div class="auth-link">
            <span class="link-text">Already have an account?</span>
            <a (click)="navigateToLogin()" class="link">Login</a>
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
      max-height: 90vh;
      overflow-y: auto;
    }

    .auth-header {
      text-align: center;
      margin-bottom: 1.5rem;
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

    .avatar-selection {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 0.5rem;
      margin-top: 0.5rem;
    }

    .avatar-option {
      width: 60px;
      height: 60px;
      border-radius: 50%;
      border: 2px solid transparent;
      cursor: pointer;
      transition: all 0.2s ease;
      overflow: hidden;
      background: white;
    }

    .avatar-option:hover {
      border-color: rgba(229, 9, 20, 0.5);
      transform: scale(1.05);
    }

    .avatar-option.selected {
      border-color: #E50914;
      box-shadow: 0 4px 20px rgba(229, 9, 20, 0.3);
    }

    .avatar-option img {
      width: 100%;
      height: 100%;
      object-fit: cover;
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

    @media (max-width: 480px) {
      .avatar-selection {
        grid-template-columns: repeat(3, 1fr);
        gap: 0.25rem;
      }

      .avatar-option {
        width: 50px;
        height: 50px;
      }
    }
  `]
})
export class RegisterComponent implements OnInit {
  registerForm: FormGroup;
  isLoading = false;
  isSubmitted = false;
  showPassword = false;
  showConfirmPassword = false;
  errorMessage = '';
  selectedAvatarIndex: number | null = null;
  selectedAvatar: string | null = null;

  avatars = [
    'https://api.dicebear.com/9.x/micah/svg?seed=Adrian',
    'https://api.dicebear.com/9.x/micah/svg?seed=Jocelyn',
    'https://api.dicebear.com/9.x/notionists-neutral/svg?seed=Jocelyn',
    'https://api.dicebear.com/9.x/bottts-neutral/svg?seed=Charlie',
    'https://api.dicebear.com/9.x/pixel-art-neutral/svg?seed=Max',
    'https://api.dicebear.com/9.x/identicon/svg?seed=Sammy'
  ];

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private router: Router
  ) {
    this.registerForm = this.fb.group({
      username: ['', [Validators.required, Validators.minLength(3)]],
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', [Validators.required]]
    }, { validators: this.passwordMatchValidator });
  }

  ngOnInit(): void {
    if (this.authService.isAuthenticated()) {
      this.router.navigate(['/home']);
    }
  }

  passwordMatchValidator(form: FormGroup) {
    const password = form.get('password');
    const confirmPassword = form.get('confirmPassword');
    
    if (password && confirmPassword && password.value !== confirmPassword.value) {
      confirmPassword.setErrors({ passwordMismatch: true });
      return { passwordMismatch: true };
    }
    
    return null;
  }

  get usernameControl() {
    return this.registerForm.get('username');
  }

  get emailControl() {
    return this.registerForm.get('email');
  }

  get passwordControl() {
    return this.registerForm.get('password');
  }

  get confirmPasswordControl() {
    return this.registerForm.get('confirmPassword');
  }

  selectAvatar(index: number): void {
    this.selectedAvatarIndex = index;
    this.selectedAvatar = this.avatars[index];
  }

  togglePassword(): void {
    this.showPassword = !this.showPassword;
  }

  toggleConfirmPassword(): void {
    this.showConfirmPassword = !this.showConfirmPassword;
  }

  onSubmit(): void {
    this.isSubmitted = true;

    if (this.registerForm.valid && this.selectedAvatar && !this.isLoading) {
      this.isLoading = true;
      this.errorMessage = '';

      const { username, email, password } = this.registerForm.value;

      this.authService.register({
        name: username,
        email,
        password,
        avatar: this.selectedAvatar
      }).subscribe({
        next: (response) => {
          this.isLoading = false;
          this.router.navigate(['/home']);
        },
        error: (error) => {
          this.isLoading = false;
          this.errorMessage = error.error?.message || 'Registration failed. Please try again.';
        }
      });
    } else if (!this.selectedAvatar) {
      this.errorMessage = 'Please select an avatar to continue.';
    }
  }

  navigateToLogin(): void {
    this.router.navigate(['/auth/login']);
  }

  goBack(): void {
    this.router.navigate(['/welcome']);
  }
}