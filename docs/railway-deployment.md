# Railway Deployment Guide

This guide walks you through deploying the SMS Messenger app to Railway, a modern hosting platform with excellent support for full-stack applications.

## Prerequisites

1. **Railway Account**: Sign up at [railway.app](https://railway.app)
2. **Railway CLI**: Install the Railway CLI
   ```bash
   # Install Railway CLI
   npm install -g @railway/cli
   
   # Login to Railway
   railway login
   ```
3. **MongoDB Atlas**: Set up a MongoDB cluster (Railway doesn't provide MongoDB)
4. **Twilio Account**: Ensure you have Twilio credentials ready

## Step 1: Prepare MongoDB Atlas

1. Go to [MongoDB Atlas](https://cloud.mongodb.com)
2. Create a new cluster (free tier is sufficient)
3. Create a database user with read/write permissions
4. Whitelist Railway's IP ranges (or use 0.0.0.0/0 for simplicity)
5. Get your connection string in the format:
   ```
   mongodb+srv://username:password@cluster.mongodb.net/database_name
   ```

## Step 2: Deploy Backend to Railway

1. **Create Railway Project**:
   ```bash
   cd /Users/jzimms/Development/my_sms_msgr
   railway new
   # Choose: "Empty Project"
   # Enter project name: "sms-messenger"
   ```

2. **Deploy Backend Service**:
   ```bash
   cd my_sms_be
   railway up --dockerfile Dockerfile.railway
   ```

3. **Set Environment Variables**:
   ```bash
   # Required environment variables
   railway variables set RAILS_ENV=production
   railway variables set RAILS_SERVE_STATIC_FILES=true
   railway variables set RAILS_LOG_TO_STDOUT=true
   railway variables set MONGODB_URI="your_mongodb_atlas_connection_string"
   railway variables set TWILIO_ACCOUNT_SID="your_twilio_account_sid"
   railway variables set TWILIO_AUTH_TOKEN="your_twilio_auth_token"
   railway variables set TWILIO_PHONE_NUMBER="your_twilio_phone_number"
   
   # Generate and set Rails master key
   railway variables set RAILS_MASTER_KEY="$(cat config/master.key)"
   
   # Optional: Set custom domain for webhook callbacks
   railway variables set APP_HOST="your-backend-domain.railway.app"
   ```

4. **Get Backend URL**:
   ```bash
   railway status
   # Note the backend URL (e.g., https://your-backend.railway.app)
   ```

## Step 3: Deploy Frontend to Railway

1. **Create Frontend Service**:
   ```bash
   cd ../my_sms_fe
   railway service new frontend
   railway up --dockerfile Dockerfile.railway
   ```

2. **Update Frontend API URL**:
   Before deploying, update the frontend to use the Railway backend URL:
   
   ```typescript
   // src/environments/environment.prod.ts (create if it doesn't exist)
   export const environment = {
     production: true,
     apiUrl: 'https://your-backend.railway.app' // Replace with actual Railway backend URL
   };
   ```

3. **Update Angular Build Configuration**:
   Ensure the production build uses the correct environment:
   ```json
   // angular.json - update build.production.fileReplacements
   "fileReplacements": [
     {
       "replace": "src/environments/environment.ts",
       "with": "src/environments/environment.prod.ts"
     }
   ]
   ```

## Step 4: Configure Twilio Webhooks

1. **Get Backend URL**: Note your Railway backend URL
2. **Update Twilio Webhook URL**:
   - Go to Twilio Console > Phone Numbers
   - Select your SMS-enabled phone number
   - Set webhook URL to: `https://your-backend.railway.app/webhooks/twilio/status`
   - Set HTTP method to: `POST`

## Step 5: Final Configuration

1. **Update CORS Settings** (if needed):
   ```ruby
   # my_sms_be/config/initializers/cors.rb
   Rails.application.config.middleware.insert_before 0, Rack::Cors do
     allow do
       origins 'https://your-frontend.railway.app' # Add your Railway frontend URL
       resource '*',
         headers: :any,
         methods: [:get, :post, :put, :patch, :delete, :options, :head]
     end
   end
   ```

2. **Test the Deployment**:
   ```bash
   # Check backend health
   curl https://your-backend.railway.app/health
   
   # Check frontend
   curl https://your-frontend.railway.app
   ```

## Environment Variables Summary

### Backend Environment Variables:
```
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
RAILS_MASTER_KEY=your_master_key_from_config_file
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/database
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_PHONE_NUMBER=your_twilio_phone_number
APP_HOST=your-backend-domain.railway.app
```

### Frontend Environment Variables:
```
NODE_ENV=production
```

## Troubleshooting

### Common Issues:

1. **MongoDB Connection Issues**:
   - Verify MongoDB Atlas connection string
   - Ensure IP whitelist includes Railway IPs (or use 0.0.0.0/0)
   - Check database user permissions

2. **Twilio Webhook Issues**:
   - Ensure webhook URL is publicly accessible
   - Check Railway logs: `railway logs`
   - Verify Twilio credentials

3. **CORS Issues**:
   - Update CORS origins in Rails initializer
   - Ensure frontend and backend URLs are correct

4. **Build Failures**:
   - Check Railway build logs: `railway logs --deployment`
   - Verify Dockerfile syntax
   - Ensure all dependencies are properly specified

### Useful Railway Commands:

```bash
# View logs
railway logs

# Check service status
railway status

# Open Railway dashboard
railway open

# Redeploy service
railway up

# Environment variables
railway variables
railway variables set KEY=value
railway variables delete KEY
```

## Production Checklist

- [ ] MongoDB Atlas cluster configured and accessible
- [ ] Backend deployed to Railway with all environment variables
- [ ] Frontend deployed to Railway with correct API URL
- [ ] Twilio webhooks configured to point to Railway backend
- [ ] CORS properly configured for frontend domain
- [ ] Health checks passing for both services
- [ ] SMS sending and status updates working end-to-end

## Monitoring and Maintenance

1. **Railway Dashboard**: Monitor deployments, logs, and metrics
2. **MongoDB Atlas**: Monitor database performance and usage
3. **Twilio Console**: Monitor SMS usage and webhook delivery
4. **Logs**: Use `railway logs` to troubleshoot issues

## Cost Optimization

- Railway offers $5/month credit for hobby plan
- MongoDB Atlas free tier provides 512MB storage
- Twilio charges per SMS sent/received
- Consider upgrading plans as usage grows

Your SMS Messenger app should now be live and accessible via the Railway URLs!
