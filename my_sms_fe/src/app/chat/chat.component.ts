import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MessageService } from '../services/message.service';
import { ValidationService } from '../services/validation.service';

@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './chat.component.html',
  styleUrls: ['./chat.component.scss']
})
export class ChatComponent implements OnInit {
  messages: any[] = [];
  phoneNumber: string = '';
  messageBody: string = '';
  sessionId: string = '';
  
  // Validation error messages
  phoneError: string = '';
  messageError: string = '';
  
  constructor(
    private messageService: MessageService,
    private validationService: ValidationService
  ) {}

  ngOnInit(): void {
    this.sessionId = 'session_' + Date.now();
    this.loadMessages();
  }

  loadMessages(): void {
    this.messageService.getMessages().subscribe({
      next: (messages) => {
        this.messages = messages;
      },
      error: (error) => {
        console.error('Error loading messages:', error);
      }
    });
  }

  sendMessage(): void {
    if (this.isFormValid()) {
      const messageData = {
        session_id: this.sessionId,
        phone_number: this.phoneNumber,
        message_body: this.messageBody
      };

      this.messageService.sendMessage(messageData).subscribe({
        next: (response) => {
          this.messages.push(response);
          this.phoneNumber = '';
          this.messageBody = '';
          this.clearErrors();
        },
        error: (error) => {
          console.error('Error sending message:', error);
        }
      });
    }
  }

  isFormValid(): boolean {
    this.validatePhone();
    this.validateMessage();
    return !this.phoneError && !this.messageError;
  }

  validatePhone(): void {
    this.phoneError = this.validationService.validatePhoneNumber(this.phoneNumber) || '';
  }

  validateMessage(): void {
    this.messageError = this.validationService.validateMessage(this.messageBody, 250) || '';
  }

  clearErrors(): void {
    this.phoneError = '';
    this.messageError = '';
  }

  getCharacterCount(): string {
    const remaining = 250 - this.messageBody.length;
    return `${this.messageBody.length}/250 characters`;
  }

  isCharacterLimitExceeded(): boolean {
    return this.messageBody.length > 250;
  }
}