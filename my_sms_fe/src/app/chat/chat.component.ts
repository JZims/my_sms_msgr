import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MessageService } from '../services/message.service';
import { ValidationService } from '../services/validation.service';
import { interval, Subscription } from 'rxjs';

@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './chat.component.html',
  styleUrls: ['./chat.component.scss']
})
export class ChatComponent implements OnInit, OnDestroy {
  messages: any[] = [];
  phoneNumber: string = '';
  messageBody: string = '';
  sessionId: string = '';
  
  // Validation error messages
  phoneError: string = '';
  messageError: string = '';
  
  // Status update polling
  private statusUpdateInterval: any;
  private readonly STATUS_CHECK_INTERVAL = 30000; // 30 seconds
  
  constructor(
    private messageService: MessageService,
    private validationService: ValidationService
  ) {}

  ngOnInit(): void {
    this.sessionId = 'session_' + Date.now();
    this.loadMessages();
    this.startStatusUpdates();
  }

  ngOnDestroy(): void {
    this.stopStatusUpdates();
  }

  private startStatusUpdates(): void {
    // Check for status updates every 30 seconds
    this.statusUpdateInterval = setInterval(() => {
      this.checkStatusUpdates();
    }, this.STATUS_CHECK_INTERVAL);
  }

  private stopStatusUpdates(): void {
    if (this.statusUpdateInterval) {
      clearInterval(this.statusUpdateInterval);
      this.statusUpdateInterval = null;
    }
  }

  private checkStatusUpdates(): void {
    // Only check if we have messages that might need updates
    const pendingMessages = this.messages.filter(msg => 
      msg.direction === 'outbound' && 
      ['sending', 'sent'].includes(msg.status)
    );
    
    if (pendingMessages.length > 0) {
      this.messageService.checkStatusUpdates().subscribe({
        next: (response) => {
          if (response.updates_count > 0) {
            this.messages = response.messages;
            console.log(`Updated ${response.updates_count} message status(es)`);
          }
        },
        error: (error) => {
          console.error('Error checking status updates:', error);
        }
      });
    }
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
          
          // Check for status updates after a short delay to catch immediate status changes
          setTimeout(() => {
            this.checkStatusUpdates();
          }, 2000);
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

  isMessagePending(message: any): boolean {
    return message.direction === 'outbound' && ['sending', 'sent'].includes(message.status);
  }

  clearForm(): void {
    this.phoneNumber = '';
    this.messageBody = '';
    this.phoneError = '';
    this.messageError = '';
  }

  getStatusDisplayText(status: string): string {
    switch (status) {
      case 'sending':
        return 'Sending';
      case 'sent':
        return 'Sent';
      case 'delivered':
        return 'Delivered';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  formatTimestamp(timestamp: string): string {
    if (!timestamp) return '';
    
    const date = new Date(timestamp);
    const now = new Date();
    const diffInHours = Math.abs(now.getTime() - date.getTime()) / (1000 * 60 * 60);
    
    // If within the last 24 hours, show relative time
    if (diffInHours < 24) {
      return date.toLocaleTimeString('en-US', { 
        hour: 'numeric', 
        minute: '2-digit',
        hour12: true 
      });
    } else {
      // Otherwise show date and time
      return date.toLocaleDateString('en-US', { 
        month: 'short', 
        day: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
        hour12: true
      });
    }
  }
}