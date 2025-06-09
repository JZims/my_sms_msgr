class AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:login, :register]

  def login
    user = User.find_by(user_name: params[:user_name])
    
    if user&.authenticate(params[:password])
      token = generate_token(user.user_name)
      render json: { 
        token: token, 
        user_name: user.user_name 
      }, status: :ok
    else
      render json: { 
        error: "Invalid username or password" 
      }, status: :unauthorized
    end
  end

  def register
    user = User.new(user_name: params[:user_name], password: params[:password])
    
    if user.save
      token = generate_token(user.user_name)
      render json: { 
        token: token, 
        user_name: user.user_name,
        message: "Registration successful" 
      }, status: :created
    else
      render json: { 
        errors: user.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  private

  def generate_token(user_name)
    # Simple token generation for basic auth
    payload = { 
      user_name: user_name, 
      exp: 24.hours.from_now.to_i 
    }
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end
