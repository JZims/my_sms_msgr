import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class ValidationService {

  validatePhoneNumber(phoneNumber: string): string | null {
    const phone = phoneNumber.trim();
    
    if (!phone) {
      return 'Phone number is required';
    }

    // Match the backend Rails validation: /\A\+?[1-9]\d{1,14}\z/
    // Optional +, starts with 1-9, followed by 1-14 digits
    const backendPattern = /^\+?[1-9]\d{1,14}$/;
    
    if (!backendPattern.test(phone)) {
      return 'Must be a valid phone number (e.g., +1234567890 or 1234567890)';
    }

    return null; // Valid
  }

  validateMessage(message: string, maxLength: number = 250): string | null {
    const msg = message.trim();
    
    if (!msg) {
      return 'Message is required';
    }

    if (msg.length > maxLength) {
      return `Message must be ${maxLength} characters or less`;
    }

    return null; // Valid
  }

  formatPhoneNumber(phoneNumber: string): string {
    // Remove all non-digit characters except +
    const digitsOnly = phoneNumber.replace(/[^\d+]/g, '');
    
    // Only allow + at the beginning
    if (digitsOnly.includes('+') && !digitsOnly.startsWith('+')) {
      return digitsOnly.replace(/\+/g, '');
    }
    
    return digitsOnly;
  }
}
