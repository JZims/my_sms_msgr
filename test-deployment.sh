#!/bin/bash

# Railway Deployment Test Script
# Use this to verify your deployment is working correctly

set -e

echo "🧪 Testing Railway SMS Messenger Deployment"
echo "=========================================="

# Get backend URL from Railway
BACKEND_URL="https://sms-backend-production-b58e.up.railway.app"

if [ -z "$BACKEND_URL" ]; then
    echo "❌ Could not get backend URL. Make sure you're connected to Railway project."
    exit 1
fi

echo "🔗 Backend URL: $BACKEND_URL"

echo ""
echo "🔍 Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s "$BACKEND_URL/health" || echo "ERROR")

if [[ "$HEALTH_RESPONSE" == *"healthy"* ]]; then
    echo "✅ Health check passed!"
    echo "$HEALTH_RESPONSE" | jq . 2>/dev/null || echo "$HEALTH_RESPONSE"
else
    echo "❌ Health check failed!"
    echo "$HEALTH_RESPONSE"
fi

echo ""
echo "🔍 Testing basic API endpoint..."
API_RESPONSE=$(curl -s "$BACKEND_URL/" || echo "ERROR")

if [[ "$API_RESPONSE" == *"SMS Chat API"* ]]; then
    echo "✅ API endpoint accessible!"
    echo "$API_RESPONSE"
else
    echo "❌ API endpoint failed!"
    echo "$API_RESPONSE"
fi

echo ""
echo "📋 Current environment variables:"
railway service sms-backend && railway variables | grep -E "(RAILS_|TWILIO_|MONGODB_)"

echo ""
echo "📊 Recent logs:"
railway service sms-backend && railway logs | tail -10

echo ""
echo "🎯 Next steps:"
echo "1. If health check shows issues, fix the failing component"
echo "2. Test frontend deployment"
echo "3. Configure Twilio webhook"
echo "4. Send test SMS message"
