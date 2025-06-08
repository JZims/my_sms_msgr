# SMS Chat Backend - Rails API

A Rails 8 API backend for SMS messaging using Twilio, MongoDB, and session-based chat management.

## Features

✅ **Twilio SMS Integration** - Send SMS messages via Twilio API with synchronous response handling  
✅ **MongoDB Storage** - Store messages with session support using Mongoid  
✅ **Session-based Chat** - Filter messages by session ID for isolated conversations  
✅ **Comprehensive Testing** - RSpec test suite with WebMock for API mocking  
✅ **Synchronous Flow** - Wait for Twilio response before storing final message status  

## API Endpoints

**POST /messages** - Send SMS message
```json
{
  "message": {
    "session_id": "chat-session-123",
    "phone_number": "+1234567890", 
    "message_body": "Hello world!"
  }
}
```

**GET /messages** - Retrieve messages (optionally filtered by session_id)
```bash
GET /messages?session_id=chat-session-123
```

## SMS Workflow

POST /messages → Validate → Call Twilio API → Store Result → Return Response

1. Create message with status "sending"
2. Call Twilio API synchronously  
3. Update status to "sent" or "failed" based on response
4. Return final result to client

## Configuration

### Twilio Credentials
```bash
bin/rails credentials:edit
```
Add:
```yaml
twilio_account_sid: your_account_sid
twilio_auth_token: your_auth_token  
twilio_phone_number: +1234567890
```

### MongoDB
- Database: `my_sms_dev` (development)
- Connection: `mongodb://localhost:27017` 
- Configuration: `config/mongoid.yml`

## Testing

```bash
# Start MongoDB
docker compose up -d mongodb

# Run all tests  
bundle exec rspec

# Run specific test file
bundle exec rspec spec/requests/messages_spec.rb
```

**Test Coverage:**
- Session-based message filtering
- Twilio API success scenarios (mocked)
- Twilio API failure scenarios (mocked) 
- Message validation
- MongoDB integration

## Development Setup

1. Install dependencies: `bundle install`
2. Start MongoDB: `docker compose up -d mongodb`  
3. Set up credentials: `bin/rails credentials:edit`
4. Run tests: `bundle exec rspec`
5. Start server: `bin/rails server`
