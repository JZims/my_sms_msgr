Rails.application.routes.draw do
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
  
  # API routes
  resources :messages, only: [:index, :create]
  
  # Root path for API info
  root to: proc { [200, {}, ["SMS Chat API v1.0"]] }
end