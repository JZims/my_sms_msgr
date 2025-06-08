import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MessageService } from '../services/message.service';
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
  
  constructor(private messageService: MessageService) {}

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
    const phoneNumber = this.newMessage.phoneNumber.trim();
    
    if (!phoneNumber) {
      this.phoneNumberError = 'Phone number is required';
      return false;
    }

    // Remove any non-digit characters except the optional leading +
    const cleanPhone = phoneNumber.replace(/[^\d+]/g, '');
    
    // Check if it has invalid characters (anything other than digits, +, spaces, hyphens, parentheses)
    if (!/^[\d\s\-\(\)\+]+$/.test(phoneNumber)) {
      this.phoneNumberError = 'Phone number can only contain digits, +, spaces, hyphens, and parentheses';
      return false;
    }
    
    // Extract digits only for length validation
    const digitsOnly = cleanPhone.replace(/^\+/, ''); // Remove leading + for digit count

    // Check if it starts with + and has valid format
    if (cleanPhone.startsWith('+')) {
      if (digitsOnly.length < 10 || digitsOnly.length > 11) {
        this.phoneNumberError = 'Phone number must be 10-11 digits (not including the optional +)';
        return false;
      }
    } else {
      if (digitsOnly.length < 10 || digitsOnly.length > 11) {
        this.phoneNumberError = 'Phone number must be 10-11 digits';
        return false;
      }
    }

    // Check if all remaining characters are digits
    if (!/^\d+$/.test(digitsOnly)) {
      this.phoneNumberError = 'Invalid phone number format';
      return false;
    }

    this.phoneNumberError = '';
    return true;
  }

  validateMessage(): boolean {
    const message = this.newMessage.messageBody.trim();
    
    if (!message) {
      this.messageError = 'Message is required';
      return false;
    }

    if (message.length > 250) {
      this.messageError = 'Message must be 250 characters or less';
      return false;
    }

    this.messageError = '';
    return true;
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
    let value = event.target.value;
    
    // Remove all non-digit characters except +
    const digitsOnly = value.replace(/[^\d+]/g, '');
    
    // Only allow + at the beginning
    if (digitsOnly.includes('+') && !digitsOnly.startsWith('+')) {
      value = digitsOnly.replace(/\+/g, '');
    } else {
      value = digitsOnly;
    }
    
    this.newMessage.phoneNumber = value;
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