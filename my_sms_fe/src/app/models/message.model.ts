export interface Message {
  _id?: string;
  session_id: string;
  phone_number: string;
  message_body: string;
  direction: 'outbound' | 'inbound';
  status: 'sending' | 'sent' | 'delivered' | 'failed';
  twilio_sid?: string;
  created_at: string;
  updated_at: string;
}

export interface SendMessageRequest {
  session_id: string;
  phone_number: string;
  message_body: string;
}