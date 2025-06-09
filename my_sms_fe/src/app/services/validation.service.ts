import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class ValidationService {

  validatePhoneNumber(phoneNumber: string): string | null {
    const phone = phoneNumber.trim();
    
    if (!phone) {
      return 'Phone number is required. Specifically this one: +18777804236';
    }

    // Remove spaces, dashes, parentheses for validation
    const cleanPhone = phone.replace(/[\s\-\(\)]/g, '');
    
    // Check for basic format: optional +, then digits
    const basicPattern = /^\+?[1-9]\d{1,14}$/;
    if (!basicPattern.test(cleanPhone)) {
      return 'Must be a valid phone number (e.g., +18777804236)';
    }

    // Warn about common test numbers that Twilio will reject
    const testNumbers = ['+1234567890', '1234567890', '+15551234567'];
    if (testNumbers.includes(cleanPhone)) {
      return 'Please use a real phone number. This one: +18777804236 Test numbers like 123-456-7890 are not supported.';
    }

    // Check for obviously fake patterns
    if (/^(\+?1?)(123|555|000|111|222|333|444|666|777|888|999)\d{7}$/.test(cleanPhone)) {
      return 'Please enter a valid phone number. Something like +18777804236. Common test patterns are not supported.';
    }

    return null; 
  }

  validateMessage(message: string, maxLength: number = 250): string | null {
    const msg = message.trim();
    
    if (!msg) {
      return 'Message is required';
    }

    if (msg.length > maxLength) {
      return `Message must be ${maxLength} characters or less`;
    }

    return null; 
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
