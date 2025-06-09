class TwilioConfig
  class << self
    def account_sid
      ENV['TWILIO_ACCOUNT_SID'] || rails_credentials_fallback(:twilio_account_sid)
    end

    def auth_token
      ENV['TWILIO_AUTH_TOKEN'] || rails_credentials_fallback(:twilio_auth_token)
    end

    def phone_number
      ENV['TWILIO_PHONE_NUMBER'] || rails_credentials_fallback(:twilio_phone_number)
    end

    def configured?
      account_sid.present? && auth_token.present? && phone_number.present?
    end

    private

    def rails_credentials_fallback(key)
      return nil unless Rails.application.credentials.respond_to?(key)
      
      begin
        Rails.application.credentials.public_send(key)
      rescue ActiveSupport::MessageEncryptor::InvalidMessage => e
        Rails.logger.warn "Could not decrypt Rails credentials for #{key}: #{e.message}"
        nil
      rescue => e
        Rails.logger.warn "Error accessing Rails credentials for #{key}: #{e.message}"
        nil
      end
    end
  end
end
