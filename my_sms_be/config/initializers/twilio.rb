Rails.application.configure do
  # Check Twilio configuration at startup in production
  if Rails.env.production?
    config.after_initialize do
      unless TwilioConfig.configured?
        missing_vars = []
        missing_vars << 'TWILIO_ACCOUNT_SID' unless TwilioConfig.account_sid.present?
        missing_vars << 'TWILIO_AUTH_TOKEN' unless TwilioConfig.auth_token.present?
        missing_vars << 'TWILIO_PHONE_NUMBER' unless TwilioConfig.phone_number.present?
        
        Rails.logger.warn "WARNING: Twilio not fully configured. Missing: #{missing_vars.join(', ')}"
        Rails.logger.warn "SMS functionality will be disabled."
      else
        Rails.logger.info "✅ Twilio configuration verified"
      end
    end
  end
end
