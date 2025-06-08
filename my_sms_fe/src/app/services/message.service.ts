import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';
import { Message, SendMessageRequest } from '../models/message.model';

@Injectable({
  providedIn: 'root'
})
export class MessageService {
  // Mock data for now - replace with actual API calls later
  private mockMessages: Message[] = [
    {
      id: '1',
      phoneNumber: '+1234567890',
      messageBody: 'Hello! This is a test message.',
      direction: 'outbound',
      timestamp: new Date(Date.now() - 3600000),
      status: 'delivered'
    },
    {
      id: '2',
      phoneNumber: '+1234567890',
      messageBody: 'Thanks for the message!',
      direction: 'inbound',
      timestamp: new Date(Date.now() - 1800000)
    }
  ];

  constructor() {}

  getMessages(): Observable<Message[]> {
    // Mock API call - returns observable of messages
    return of(this.mockMessages);
  }

  sendMessage(request: SendMessageRequest): Observable<Message> {
    // Mock sending message - replace with actual backend API call
    const newMessage: Message = {
      id: (this.mockMessages.length + 1).toString(),
      phoneNumber: request.phoneNumber,
      messageBody: request.messageBody,
      direction: 'outbound',
      timestamp: new Date(),
      status: 'sent'
    };
    
    this.mockMessages.push(newMessage);
    return of(newMessage);
  }
}