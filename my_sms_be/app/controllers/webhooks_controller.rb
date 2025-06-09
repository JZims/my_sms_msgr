class WebhooksController < ApplicationController
  skip_before_action :authenticate_user!
  
  def twilio_status
    message_sid = params['MessageSid']
    message_status = params['MessageStatus']
    
    if message_sid && message_status
      message = Message.find_by(twilio_sid: message_sid)
      
      if message
        old_status = message.status
        new_status = map_twilio_status(message_status)
        
        # Only update if status has actually changed
        if old_status != new_status
          message.update(status: new_status)
          Rails.logger.info "Updated message #{message_sid} status from #{old_status} to #{new_status}"
          
          # Here we could broadcast the update via WebSocket or Action Cable
          # ActionCable.server.broadcast("user_#{message.user_name}", {
          #   type: 'message_status_update',
          #   message_id: message.id.to_s,
          #   status: new_status
          # })
        end
        
        render json: { status: 'success' }, status: :ok
      else
        Rails.logger.warn "Received status update for unknown message SID: #{message_sid}"
        render json: { error: 'Message not found' }, status: :not_found
      end
    else
      Rails.logger.warn "Invalid webhook payload: missing MessageSid or MessageStatus"
      render json: { error: 'Invalid payload' }, status: :bad_request
    end
  end

  private

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
