Rails.application.routes.draw do
  # Health check endpoints
  get "up" => "rails/health#show", as: :rails_health_check
  get "health" => proc { [200, {'Content-Type' => 'application/json'}, ['{"status":"ok"}']] }
  
  # Authentication
  post '/login', to: 'auth#login'
  post '/register', to: 'auth#register'
  
  # API routes
  resources :messages, only: [:index, :create] do
    collection do
      get :check_status_updates
    end
  end
  
  # Twilio webhooks
  post '/webhooks/twilio/status', to: 'webhooks#twilio_status'
  
  # Root path for API info
  root to: proc { [200, {}, ["SMS Chat API v1.0"]] }
end