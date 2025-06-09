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

    // Check if it has invalid characters
    if (!/^[\d\s\-\(\)\+]+$/.test(phone)) {
      return 'Phone number can only contain digits, +, spaces, hyphens, and parentheses';
    }
    
    // Extract digits only for length validation
    const cleanPhone = phone.replace(/[^\d+]/g, '');
    const digitsOnly = cleanPhone.replace(/^\+/, '');

    // Check digit count
    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      return 'Phone number must be 10-11 digits';
    }

    // Check if all remaining characters are digits
    if (!/^\d+$/.test(digitsOnly)) {
      return 'Invalid phone number format';
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
