class MessagesControler < ApplicationController
    def index
        render json: Message.all.order_by(created_at: :desc)
    end

    def create 
        message = Message.new(message_params.merge(direction: 'outbound', status: 'sending'))
        if message.save
            send_sms(message)
            render json: message, status: :created
        else
        render json: { errors: message.errors }, status: :unprocessable_entity
    end
  end
    private

    def message_params
        params.require(:message).permit(:phone_number, :message_body)
    end

    def send_sms(message)
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

            message.update(status: 'sent', twilio_sid: twilio_message.sid)
        rescue => e
            message.update(status: 'failed')
            Rails.logger.error "SMS failed: #{e.message}"
        end
    end
end