import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { Message, SendMessageRequest, ApiErrorResponse } from '../models/message.model';
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class MessageService {
  private apiUrl = 'http://localhost:3000';

  constructor(private http: HttpClient) {}

  private getAuthHeaders(): HttpHeaders {
    const token = localStorage.getItem('auth_token');
    return new HttpHeaders({
      'Authorization': token ? `Bearer ${token}` : '',
      'Content-Type': 'application/json'
    });
  }

  sendMessage(messageData: SendMessageRequest): Observable<Message> {
    const headers = this.getAuthHeaders();
    return this.http.post<Message>(`${this.apiUrl}/messages`, { message: messageData }, { headers });
  }

  getMessages(sessionId?: string): Observable<Message[]> {
    let params = new HttpParams();
    if (sessionId) {
      params = params.set('session_id', sessionId);
    }
    const headers = this.getAuthHeaders();
    return this.http.get<Message[]>(`${this.apiUrl}/messages`, { params, headers });
  }

  checkStatusUpdates(): Observable<{messages: Message[], updates_count: number}> {
    const headers = this.getAuthHeaders();
    return this.http.get<{messages: Message[], updates_count: number}>(`${this.apiUrl}/messages/check_status_updates`, { headers });
  }
}