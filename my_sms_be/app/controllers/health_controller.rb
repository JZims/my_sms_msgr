class HealthController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    health_checks = {
      rails: 'ok',
      mongodb: check_mongodb,
      twilio: check_twilio_config
    }
    
    status = health_checks.values.all? { |v| v == 'ok' } ? :ok : :service_unavailable
    
    render json: {
      status: status == :ok ? 'healthy' : 'unhealthy',
      checks: health_checks,
      timestamp: Time.current.iso8601
    }, status: status
  end

  private

  def check_mongodb
    begin
      # Try to perform a simple MongoDB operation
      Message.count
      'ok'
    rescue => e
      Rails.logger.error "MongoDB health check failed: #{e.message}"
      'error'
    end
  end

  def check_twilio_config
    if TwilioConfig.configured?
      'ok'
    else
      Rails.logger.warn "Twilio configuration incomplete"
      'warning'
    end
  end
end
