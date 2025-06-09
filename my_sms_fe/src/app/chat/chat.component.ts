import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MessageService } from '../services/message.service';
import { ValidationService } from '../services/validation.service';
import { Message, SendMessageRequest } from '../models/message.model';

@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './chat.component.html',
  styleUrls: ['./chat.component.scss']
})
export class ChatComponent implements OnInit {
  messages: Message[] = [];
  newMessage: SendMessageRequest = {
    phoneNumber: '',
    messageBody: ''
  };
  
  // Validation properties
  phoneNumberError: string = '';
  messageError: string = '';
  
  constructor(
    private messageService: MessageService,
    private validationService: ValidationService
  ) {}

  ngOnInit(): void {
    this.loadMessages();
  }

  loadMessages(): void {
    this.messageService.getMessages().subscribe({
      next: (messages) => {
        this.messages = messages.sort((a, b) => 
          new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime()
        );
      },
      error: (error) => {
        console.error('Error loading messages:', error);
      }
    });
  }

  sendMessage(): void {
    // Validate inputs before sending
    if (!this.validatePhoneNumber() || !this.validateMessage()) {
      return;
    }

    this.messageService.sendMessage(this.newMessage).subscribe({
      next: (message) => {
        this.messages.push(message);
        this.newMessage = { phoneNumber: '', messageBody: '' };
        this.clearValidationErrors();
      },
      error: (error) => {
        console.error('Error sending message:', error);
      }
    });
  }

  validatePhoneNumber(): boolean {
    const error = this.validationService.validatePhoneNumber(this.newMessage.phoneNumber);
    this.phoneNumberError = error || '';
    return !error;
  }

  validateMessage(): boolean {
    const error = this.validationService.validateMessage(this.newMessage.messageBody);
    this.messageError = error || '';
    return !error;
  }

  clearValidationErrors(): void {
    this.phoneNumberError = '';
    this.messageError = '';
  }

  // Method to check if form is valid for button state
  isFormValid(): boolean {
    return this.newMessage.phoneNumber.trim() !== '' && 
           this.newMessage.messageBody.trim() !== '' &&
           this.phoneNumberError === '' &&
           this.messageError === '';
  }

  // Method to get remaining character count
  getRemainingChars(): number {
    return 250 - this.newMessage.messageBody.length;
  }

  // Helper method to format phone number as user types
  onPhoneNumberInput(event: any): void {
    const formatted = this.validationService.formatPhoneNumber(event.target.value);
    this.newMessage.phoneNumber = formatted;
    this.validatePhoneNumber();
  }

  // Helper method to validate on message input
  onMessageInput(): void {
    this.validateMessage();
  }

  formatTime(timestamp: Date): string {
    return new Date(timestamp).toLocaleTimeString('en-US', {
      hour: '2-digit',
      minute: '2-digit'
    });
  }
}