class MessagesController < ApplicationController
  def index
    messages = if params[:session_id].present?
                 Message.where(session_id: params[:session_id])
               else
                 Message.all
               end
    
    render json: messages.order_by(created_at: :desc)
  end

  def create 
    message = Message.new(message_params.merge(direction: 'outbound', status: 'sending'))
    if message.save
      success = send_sms(message)
      if success
        render json: message, status: :created
      else
        render json: { errors: ["SMS failed to send. Status: #{message.status}"] }, status: :unprocessable_entity
      end
    else
      render json: { errors: message.errors }, status: :unprocessable_entity
    end
  end
    private

    def message_params
        params.require(:message).permit(:session_id, :phone_number, :message_body)
    end

    def send_sms(message)
        # Use real Twilio integration for all environments
        client = Twilio::REST::Client.new(
            Rails.application.credentials.twilio_account_sid,
            Rails.application.credentials.twilio_auth_token
        )

        begin
            twilio_message = client.messages.create(
                from: Rails.application.credentials.twilio_phone_number,
                to: message.phone_number,
                body: message.message_body
            )

            # Update message with Twilio response details
            twilio_status = map_twilio_status(twilio_message.status)
            message.update(status: twilio_status, twilio_sid: twilio_message.sid)
            
            Rails.logger.info "SMS sent to #{message.phone_number} with SID: #{twilio_message.sid}, Status: #{twilio_message.status}"
            true
        rescue Twilio::REST::RestError => e
            message.update(status: 'failed')
            Rails.logger.error "Twilio API error: #{e.message} (Code: #{e.code})"
            false
        rescue => e
            message.update(status: 'failed')
            Rails.logger.error "SMS failed: #{e.message}"
            false
        end
    end

    # Map Twilio message statuses to our internal statuses
    def map_twilio_status(twilio_status)
        case twilio_status
        when 'queued', 'sending'
            'sending'
        when 'sent', 'delivered'
            'sent'
        when 'failed', 'undelivered'
            'failed'
        else
            'sent' # Default to sent for unknown statuses
        end
    end
end