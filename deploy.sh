#!/bin/bash

# Railway Deployment Script for SMS Messenger App
# This script automates the deployment process to Railway

set -e

echo "🚀 SMS Messenger Railway Deployment Script"
echo "=========================================="

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI is not installed. Please install it first:"
    echo "npm install -g @railway/cli"
    exit 1
fi

# Check if user is logged in to Railway
if ! railway whoami &> /dev/null; then
    echo "❌ You are not logged in to Railway. Please login first:"
    echo "railway login"
    exit 1
fi

echo "✅ Railway CLI detected and user logged in"

# Function to check if environment variable is set
check_env_var() {
    local var_name=$1
    if [ -z "${!var_name}" ]; then
        echo "❌ Environment variable $var_name is not set"
        echo "Please set it using: export $var_name=your_value"
        return 1
    fi
    return 0
}

# Check required environment variables
echo ""
echo "🔍 Checking required environment variables..."

required_vars=(
    "MONGODB_URI"
    "TWILIO_ACCOUNT_SID"
    "TWILIO_AUTH_TOKEN"
    "TWILIO_PHONE_NUMBER"
)

for var in "${required_vars[@]}"; do
    if ! check_env_var "$var"; then
        echo ""
        echo "💡 You can set environment variables by:"
        echo "1. Creating a .env file (copy from .env.example)"
        echo "2. Exporting them: export VAR_NAME=value"
        echo "3. Loading from .env: source .env"
        exit 1
    fi
done

echo "✅ All required environment variables are set"

# Read Rails master key
if [ ! -f "my_sms_be/config/master.key" ]; then
    echo "❌ Rails master key not found at my_sms_be/config/master.key"
    exit 1
fi

RAILS_MASTER_KEY=$(cat my_sms_be/config/master.key)
echo "✅ Rails master key loaded"

# Create Railway project if it doesn't exist
echo ""
echo "🏗️  Setting up Railway project..."

# Check if we're already in a Railway project
if ! railway status &> /dev/null; then
    echo "Creating new Railway project..."
    railway new --name "sms-messenger"
else
    echo "✅ Railway project already exists"
fi

# Deploy backend
echo ""
echo "🔧 Deploying backend service..."
cd my_sms_be

# Create backend service if it doesn't exist
railway service create backend || echo "Backend service already exists"

# Set environment variables for backend
echo "Setting backend environment variables..."
railway variables set \
    RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_MASTER_KEY="$RAILS_MASTER_KEY" \
    MONGODB_URI="$MONGODB_URI" \
    TWILIO_ACCOUNT_SID="$TWILIO_ACCOUNT_SID" \
    TWILIO_AUTH_TOKEN="$TWILIO_AUTH_TOKEN" \
    TWILIO_PHONE_NUMBER="$TWILIO_PHONE_NUMBER"

# Deploy backend
echo "Deploying backend..."
railway up --dockerfile Dockerfile.railway

# Get backend URL
BACKEND_URL=$(railway domain | head -n 1)
echo "✅ Backend deployed to: $BACKEND_URL"

# Deploy frontend
echo ""
echo "🎨 Deploying frontend service..."
cd ../my_sms_fe

# Update production environment with backend URL
echo "Updating frontend environment configuration..."
cat > src/environments/environment.prod.ts << EOF
export const environment = {
  production: true,
  apiUrl: 'https://$BACKEND_URL'
};
EOF

# Create frontend service if it doesn't exist
railway service create frontend || echo "Frontend service already exists"

# Set environment variables for frontend
echo "Setting frontend environment variables..."
railway variables set NODE_ENV=production

# Deploy frontend
echo "Deploying frontend..."
railway up --dockerfile Dockerfile.railway

# Get frontend URL
FRONTEND_URL=$(railway domain | head -n 1)
echo "✅ Frontend deployed to: $FRONTEND_URL"

# Final setup instructions
cd ..
echo ""
echo "🎉 Deployment Complete!"
echo "====================="
echo ""
echo "📱 Frontend URL: https://$FRONTEND_URL"
echo "🔧 Backend URL:  https://$BACKEND_URL"
echo ""
echo "🔔 Next Steps:"
echo "1. Configure Twilio webhook URL: https://$BACKEND_URL/webhooks/twilio/status"
echo "2. Update CORS settings if needed in Rails backend"
echo "3. Test the application by sending SMS messages"
echo ""
echo "📊 Monitor your deployment:"
echo "railway logs                    # View logs"
echo "railway status                  # Check status"
echo "railway open                    # Open Railway dashboard"
echo ""
echo "Happy messaging! 🚀"
