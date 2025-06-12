import { Component, EventEmitter, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-login-modal',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="modal-overlay">
      <div class="modal-content">
        <h2>{{ isRegisterMode ? 'Register' : 'Login' }}</h2>
        
        <form (ngSubmit)="onSubmit()" #authForm="ngForm">
          <div class="form-group">
            <label for="username">Username:</label>
            <input 
              type="text" 
              id="username" 
              name="username" 
              [(ngModel)]="username" 
              required 
              minlength="3"
              #usernameInput="ngModel"
              class="form-control">
            <div *ngIf="usernameInput.invalid && usernameInput.touched" class="error">
              Username is required (min 3 characters)
            </div>
          </div>

          <div class="form-group">
            <label for="password">Password:</label>
            <input 
              type="password" 
              id="password" 
              name="password" 
              [(ngModel)]="password" 
              required 
              minlength="6"
              #passwordInput="ngModel"
              class="form-control">
            <div *ngIf="passwordInput.invalid && passwordInput.touched" class="error">
              Password is required (min 6 characters)
            </div>
          </div>

          <div *ngIf="errorMessage" class="error">
            {{ errorMessage }}
          </div>

          <div class="button-group">
            <button 
              type="submit" 
              [disabled]="authForm.invalid || isLoading"
              class="btn btn-primary">
              {{ isLoading ? 'Please wait...' : (isRegisterMode ? 'Register' : 'Login') }}
            </button>
          </div>
        </form>

        <div class="toggle-mode">
          <p>
            {{ isRegisterMode ? 'Already have an account?' : "Don't have an account?" }}
            <button type="button" (click)="toggleMode()" class="link-button">
              {{ isRegisterMode ? 'Login' : 'Register' }}
            </button>
          </p>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .modal-overlay {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background-color: rgba(0, 0, 0, 0.8);
      display: flex;
      justify-content: center;
      align-items: center;
      z-index: 1000;
    }

    .modal-content {
      background: white;
      padding: 2rem;
      border-radius: 8px;
      width: 90%;
      max-width: 400px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
    }

    h2 {
      text-align: center;
      margin-bottom: 1.5rem;
      color: #333;
    }

    .form-group {
      margin-bottom: 1rem;
    }

    label {
      display: block;
      margin-bottom: 0.5rem;
      font-weight: 500;
      color: #555;
    }

    .form-control {
      width: 100%;
      padding: 0.75rem;
      border: 1px solid #ddd;
      border-radius: 4px;
      font-size: 1rem;
      box-sizing: border-box;
    }

    .form-control:focus {
      outline: none;
      border-color: #007bff;
      box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
    }

    .error {
      color: #dc3545;
      font-size: 0.875rem;
      margin-top: 0.25rem;
    }

    .button-group {
      margin: 1.5rem 0 1rem 0;
    }

    .btn {
      width: 100%;
      padding: 0.75rem;
      font-size: 1rem;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      transition: background-color 0.2s;
    }

    .btn-primary {
      background-color: #007bff;
      color: white;
    }

    .btn-primary:hover:not(:disabled) {
      background-color: #0056b3;
    }

    .btn:disabled {
      background-color: #6c757d;
      cursor: not-allowed;
    }

    .toggle-mode {
      text-align: center;
      margin-top: 1rem;
    }

    .toggle-mode p {
      margin: 0;
      color: #666;
    }

    .link-button {
      background: none;
      border: none;
      color: #007bff;
      cursor: pointer;
      text-decoration: underline;
      font-size: inherit;
      margin-left: 0.25rem;
    }

    .link-button:hover {
      color: #0056b3;
    }
  `]
})
export class LoginModalComponent {
  @Output() authenticated = new EventEmitter<void>();

  username = '';
  password = '';
  isRegisterMode = false;
  isLoading = false;
  errorMessage = '';

  constructor(private authService: AuthService) {}

  onSubmit(): void {
    if (this.username.trim() && this.password.trim()) {
      this.isLoading = true;
      this.errorMessage = '';

      const authObservable = this.isRegisterMode 
        ? this.authService.register(this.username.trim(), this.password.trim())
        : this.authService.login(this.username.trim(), this.password.trim());

      authObservable.subscribe({
        next: (response) => {
          this.isLoading = false;
          this.authenticated.emit();
        },
        error: (error) => {
          this.isLoading = false;
          if (error.error?.error) {
            this.errorMessage = error.error.error;
          } else if (error.error?.errors) {
            this.errorMessage = error.error.errors.join(', ');
          } else {
            this.errorMessage = 'Authentication failed. Please try again.';
          }
        }
      });
    }
  }

  toggleMode(): void {
    this.isRegisterMode = !this.isRegisterMode;
    this.errorMessage = '';
    this.username = '';
    this.password = '';
  }
}
