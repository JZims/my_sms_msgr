import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { environment } from '../../environments/environment';

interface AuthResponse {
  token: string;
  user_name: string;
  message?: string;
}

interface AuthError {
  error?: string;
  errors?: string[];
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly baseUrl = environment.apiUrl;
  private isAuthenticatedSubject = new BehaviorSubject<boolean>(false);
  public isAuthenticated$ = this.isAuthenticatedSubject.asObservable();
  
  private currentUserSubject = new BehaviorSubject<string | null>(null);
  public currentUser$ = this.currentUserSubject.asObservable();

  constructor(private http: HttpClient) {
    // Check for existing token on service initialization
    this.checkExistingAuth();
  }

  private checkExistingAuth(): void {
    const token = localStorage.getItem('auth_token');
    const username = localStorage.getItem('username');
    
    if (token && username) {
      this.isAuthenticatedSubject.next(true);
      this.currentUserSubject.next(username);
    }
  }

  login(username: string, password: string): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.baseUrl}/login`, {
      user_name: username,
      password: password
    }).pipe(
      tap(response => {
        this.setAuthData(response.token, response.user_name);
      })
    );
  }

  register(username: string, password: string): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.baseUrl}/register`, {
      user_name: username,
      password: password
    }).pipe(
      tap(response => {
        this.setAuthData(response.token, response.user_name);
      })
    );
  }

  private setAuthData(token: string, username: string): void {
    localStorage.setItem('auth_token', token);
    localStorage.setItem('username', username);
    this.isAuthenticatedSubject.next(true);
    this.currentUserSubject.next(username);
  }

  logout(): void {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('username');
    this.isAuthenticatedSubject.next(false);
    this.currentUserSubject.next(null);
  }

  getToken(): string | null {
    return localStorage.getItem('auth_token');
  }

  getCurrentUser(): string | null {
    return localStorage.getItem('username');
  }
}
