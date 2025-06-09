import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { Message, SendMessageRequest, ApiErrorResponse } from '../models/message.model';
import { HttpClient, HttpParams } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class MessageService {
  private apiUrl = 'http://localhost:3000';

  constructor(private http: HttpClient) {}

  sendMessage(messageData: SendMessageRequest): Observable<Message> {
    return this.http.post<Message>(`${this.apiUrl}/messages`, { message: messageData });
  }

  getMessages(sessionId?: string): Observable<Message[]> {
    let params = new HttpParams();
    if (sessionId) {
      params = params.set('session_id', sessionId);
    }
    return this.http.get<Message[]>(`${this.apiUrl}/messages`, { params });
  }
}