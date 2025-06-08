export interface Message {
  id?: string;
  phoneNumber: string; // Add Validation - 10 Digits
  messageBody: string; // Add Validation - 250 Characters
  direction: 'outbound' | 'inbound';
  timestamp: Date;
  status?: 'sent' | 'delivered' | 'failed';
}

export interface SendMessageRequest {
  phoneNumber: string;
  messageBody: string;
}