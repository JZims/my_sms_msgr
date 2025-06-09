# SMS Messenger App

A modern, real-time SMS messaging application built with Rails API backend and Angular frontend, featuring dynamic read receipts and clean, minimalist design.

## 🚀 Features

- **Real-time SMS messaging** via Twilio integration
- **Dynamic read receipts** with automatic status updates
- **Clean, minimalist UI** without manual refresh buttons or emoji clutter
- **Webhook-based status updates** for real-time message delivery tracking
- **User authentication** with JWT tokens
- **MongoDB database** for scalable message storage
- **Docker containerization** for consistent deployment
- **Railway deployment ready** with production Dockerfiles

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

### Development Setup

1. **Clone and setup**:
   ```bash
   git clone <repository-url>
   cd my_sms_msgr
   cp .env.example .env
   # Edit .env with your Twilio credentials
   ```

2. **Start with Docker**:
   ```bash
   docker-compose up
   ```

3. **Access the application**:
   - Frontend: http://localhost:4200
   - Backend API: http://localhost:3000

### Production Deployment (Railway)

1. **Automated deployment**:
   ```bash
   # Set environment variables
   export MONGODB_URI="your_mongodb_atlas_uri"
   export TWILIO_ACCOUNT_SID="your_sid"
   export TWILIO_AUTH_TOKEN="your_token"
   export TWILIO_PHONE_NUMBER="your_number"
   
   # Deploy
   ./deploy.sh
   ```

2. **Manual deployment**: See [Railway Deployment Guide](docs/railway-deployment.md)

## 📁 Project Structure

```
my_sms_msgr/
├── my_sms_be/                 # Rails API backend
│   ├── app/
│   │   ├── controllers/       # API controllers
│   │   ├── models/           # Data models
│   │   └── jobs/             # Background jobs
│   ├── config/               # Rails configuration
│   ├── Dockerfile.railway    # Production Dockerfile
│   └── Dockerfile.dev        # Development Dockerfile
├── my_sms_fe/                # Angular frontend
│   ├── src/
│   │   ├── app/              # Angular components
│   │   └── environments/     # Environment configs
│   ├── Dockerfile.railway    # Production Dockerfile
│   └── nginx.conf           # Production nginx config
├── docs/                     # Documentation
├── compose.yaml             # Development Docker Compose
├── compose.prod.yaml        # Production Docker Compose
├── railway.yml              # Railway configuration
└── deploy.sh               # Automated deployment script
```

## 🔧 Configuration

### Environment Variables

**Required for deployment**:
- `MONGODB_URI` - MongoDB connection string
- `TWILIO_ACCOUNT_SID` - Twilio Account SID
- `TWILIO_AUTH_TOKEN` - Twilio Auth Token
- `TWILIO_PHONE_NUMBER` - Your Twilio phone number
- `RAILS_MASTER_KEY` - Rails secret key (auto-generated)

**Optional**:
- `APP_HOST` - Backend domain for webhook callbacks

### Twilio Webhook Setup

Configure your Twilio phone number webhook URL to:
```
https://your-backend.railway.app/webhooks/twilio/status
```

## 🧪 API Endpoints

### Authentication
- `POST /login` - User login
- `POST /register` - User registration

### Messages
- `GET /messages` - Get message history
- `POST /messages` - Send new message
- `GET /messages/check_status_updates` - Manual status check

### Webhooks
- `POST /webhooks/twilio/status` - Twilio status webhook

### Health
- `GET /health` - Health check endpoint
- `GET /up` - Rails health check

## 🎨 UI Features

- **Clean Design**: Minimalist interface focused on messaging
- **Color-coded Status**: Visual status indicators for message states
- **Responsive Layout**: Works on desktop and mobile devices
- **Real-time Updates**: No manual refresh needed
- **Loading States**: Smooth UX during message sending

## 🔄 Message Flow

1. User types message and hits send
2. Frontend sends request to Rails API
3. Rails API sends SMS via Twilio with status callback URL
4. Twilio delivers SMS and posts status updates to webhook
5. Rails updates message status in database
6. Frontend polls for status updates every 30 seconds
7. UI automatically updates with latest status

## 📚 Documentation

- [Railway Deployment Guide](docs/railway-deployment.md) - Complete Railway deployment instructions
- [API Documentation](docs/api-documentation.md) - API endpoint details
- [Development Notes](docs/dev-notes.md) - Development setup and notes

## 🛠️ Development

### Local Development
```bash
# Start development environment
docker-compose up

# Backend only
cd my_sms_be && rails server

# Frontend only
cd my_sms_fe && ng serve
```

### Testing Production Build
```bash
# Test production containers locally
docker-compose -f compose.prod.yaml up
```

## 🚢 Deployment Options

1. **Railway** (Recommended) - Use `./deploy.sh` for automated deployment
2. **Docker** - Use production Dockerfiles with any container platform
3. **Traditional** - Deploy Rails and Angular separately to VPS/cloud

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

---

Built with ❤️ using Rails, Angular, and Twilio