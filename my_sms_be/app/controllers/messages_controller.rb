class MessagesController < ApplicationController
  def index
    messages = Message.for_user(current_user_name)
    render json: messages.order_by(created_at: :desc)
  end

  def create 
    message = Message.new(message_params.merge(
      user_name: current_user_name,
      direction: 'outbound', 
      status: 'sending'
    ))
    
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

  def check_status_updates
    # Find recent outbound messages that might need status updates
    recent_messages = Message.for_user(current_user_name)
                            .where(direction: 'outbound')
                            .where(status: ['sending', 'sent'])
                            .where(:created_at.gte => 24.hours.ago)
    
    updated_count = 0
    recent_messages.each do |message|
      if message.twilio_sid.present?
        begin
          # Use TwilioConfig for robust credential handling
          unless TwilioConfig.configured?
            Rails.logger.error "Twilio credentials not configured for status check"
            next
          end

          client = Twilio::REST::Client.new(TwilioConfig.account_sid, TwilioConfig.auth_token)
          
          twilio_message = client.messages(message.twilio_sid).fetch
          new_status = map_twilio_status(twilio_message.status)
          
          if message.status != new_status
            message.update(status: new_status)
            updated_count += 1
            Rails.logger.info "Updated message #{message.twilio_sid} status to #{new_status}"
          end
        rescue => e
          Rails.logger.error "Failed to check status for message #{message.twilio_sid}: #{e.message}"
        end
      end
    end
    
    # Return fresh messages list
    messages = Message.for_user(current_user_name)
    render json: { 
      messages: messages.order_by(created_at: :desc),
      updates_count: updated_count 
    }
  end

  private

  def message_params
    params.require(:message).permit(:phone_number, :message_body)
  end

    def send_sms(message)
        # Use TwilioConfig for robust credential handling
        unless TwilioConfig.configured?
          Rails.logger.error "Twilio credentials not configured"
          message.update(status: 'failed')
          return false
        end

        client = Twilio::REST::Client.new(TwilioConfig.account_sid, TwilioConfig.auth_token)

        begin
            # Set up status callback URL for webhook updates
            status_callback_url = "#{request.base_url}/webhooks/twilio/status"
            
            twilio_message = client.messages.create(
                from: TwilioConfig.phone_number,
                to: message.phone_number,
                body: message.message_body,
                status_callback: status_callback_url
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
        when 'sent'
            'sent'
        when 'delivered'
            'delivered'
        when 'failed', 'undelivered'
            'failed'
        else
            'sent' # Default to sent for unknown statuses
        end
    end
end