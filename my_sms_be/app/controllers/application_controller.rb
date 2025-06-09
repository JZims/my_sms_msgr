class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_internal_error

  private

  def handle_internal_error(exception)
    Rails.logger.error "Internal error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    render json: { 
      errors: "An internal error occurred" 
    }, status: :internal_server_error
  end
end
