# SMS Messenger App

A modern, real-time SMS messaging application built with Rails API backend and Angular frontend, featuring dynamic read receipts and clean, minimalist design.

## 📺 Demo

![SMS Messenger Demo](my_sms_demo.gif)
*Text Messages!*

## 🚀 Features

- **Real-time SMS messaging** via Twilio integration
- **Dynamic read receipts** with automatic status updates
- **User authentication** with JWT tokens
- **MongoDB database** for scalable message storage
- **Docker containerization** for consistent (eventual) deployment

## 📱 Message Status Flow

1. **Sending** - Message is being sent via Twilio
2. **Sent** - Message successfully sent to carrier
3. **Delivered** - Message delivered to recipient's device
4. **Failed** - Message failed to send/deliver

Status updates happen automatically via:
- Twilio webhooks for real-time updates
- Background polling every 30 seconds as fallback

## 🏗️ Architecture

### Backend (Rails API)
- **Framework**: Ruby on Rails 7+ (API mode)
- **Database**: MongoDB with Mongoid ODM
- **Authentication**: JWT-based auth
- **SMS Provider**: Twilio API
- **Real-time**: Webhook endpoints for status updates

### Frontend (Angular)
- **Framework**: Angular 18+
- **Styling**: SCSS with clean, responsive design
- **HTTP Client**: Angular HttpClient with interceptors
- **Real-time**: Automatic polling for status updates

## 🚀 Quick Start

### Local Development

1. **Clone & setup**:
   ```bash
   git clone https://github.com/JZims/my_sms_msgr.git
   cd my_sms_msgr
   cp .env.example .env
   ```

2. **Add your Twilio credentials to `.env`**:
   ```bash
   TWILIO_ACCOUNT_SID=your_account_sid
   TWILIO_AUTH_TOKEN=your_auth_token  
   TWILIO_PHONE_NUMBER=your_twilio_number
   ```

3. **Start everything with Docker**:
   ```bash
   docker compose up
   ```

4. **Access the app**:
   - Frontend: http://localhost:4200
   - Backend API: http://localhost:3000
   - MongoDB: localhost:27017

**That's it!** The app will auto-create the database and you can start sending SMS messages.

## 📁 Project Structure

```
my_sms_msgr/
├── my_sms_be/                 # Rails API backend
│   ├── app/                   # Application code
│   ├── config/                # Rails configuration
│   └── Dockerfile            # Production container
├── my_sms_fe/                # Angular frontend  
│   ├── src/app/              # Angular components
│   ├── Dockerfile            # Production container
│   └── nginx.conf            # Production web server
├── compose.yaml              # Development environment
├── compose.prod.yaml         # Production environment
└── README.md                 # This file
```

## 🔧 Configuration

**Required environment variables:**
- `TWILIO_ACCOUNT_SID` - Your Twilio Account SID
- `TWILIO_AUTH_TOKEN` - Your Twilio Auth Token  
- `TWILIO_PHONE_NUMBER` - Your Twilio phone number
- `MONGODB_URI` - MongoDB connection string (auto-configured in Docker)

**For production deployment, also configure:**
- `RAILS_MASTER_KEY` - Rails secret key  
- `APP_HOST` - Your backend domain for webhook callbacks

**Twilio webhook URL (for production):**
```
https://your-backend-domain.com/webhooks/twilio/status
```

## 🧪 API Endpoints

- `POST /login` - User authentication
- `POST /register` - User registration  
- `GET /messages` - Get message history
- `POST /messages` - Send new SMS message
- `POST /webhooks/twilio/status` - Twilio status updates
- `GET /health` - Health check

## 🛠️ Development

**Backend only:**
```bash
cd my_sms_be && rails server
```

**Frontend only:**
```bash  
cd my_sms_fe && ng serve
```

**Production build test:**
```bash
docker compose -f compose.prod.yaml up
```

## 🚀 Production Deployment

### Prerequisites
- Docker & Docker Compose installed
- Twilio account with SMS capabilities
- Public domain/server for webhooks

### Deploy Steps

1. **Configure environment:**
   ```bash
   # Add production values to compose.prod.yaml
   TWILIO_ACCOUNT_SID=your_account_sid
   TWILIO_AUTH_TOKEN=your_auth_token  
   TWILIO_PHONE_NUMBER=your_twilio_number
   SECRET_KEY_BASE=your_rails_secret_key
   ```

2. **Build and start production containers:**
   ```bash
   docker compose -f compose.prod.yaml up --build -d
   ```

3. **Setup ngrok for webhooks (development/testing):**
   ```bash
   ngrok http 3000
   # Copy the https URL for Twilio webhook configuration
   ```

4. **Configure Twilio webhook:**
   - Go to Twilio Console > Phone Numbers > Manage > Active Numbers
   - Click on your Twilio phone number
   - Set webhook URL: `https://your-ngrok-url.ngrok.app/webhooks/twilio/status`
   - Set HTTP method: `POST`
   - **⚠️ IMPORTANT:** Never use `localhost` URLs - Twilio can't reach them!

5. **Verify deployment:**
   - Frontend: `http://localhost:4200`
   - Backend: `http://localhost:3000`
   - Webhook: `https://your-ngrok-url.ngrok.app/webhooks/twilio/status`

**Production URLs:**
- Replace ngrok with your actual domain for production
- Ensure SSL/HTTPS for webhook endpoints
- Configure firewall rules for ports 3000, 4200, 27017

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

---

Built with ❤️ using Rails, Angular, and Twilio
