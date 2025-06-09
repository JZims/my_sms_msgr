class ApplicationController < ActionController::API
  before_action :authenticate_user!
  
  rescue_from StandardError, with: :handle_internal_error

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    
    if token
      begin
        decoded = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' })
        @current_user_name = decoded[0]['user_name']
      rescue JWT::DecodeError
        render json: { error: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { error: 'No token provided' }, status: :unauthorized
    end
  end

  def current_user_name
    @current_user_name
  end

  def handle_internal_error(exception)
    Rails.logger.error "Internal error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    render json: { 
      errors: "An internal error occurred" 
    }, status: :internal_server_error
  end
end
