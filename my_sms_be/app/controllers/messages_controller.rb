class MessagesController < ApplicationController
    def index
        session_id = params[:session_id]
        messages = session_id ? Message.for_session(session_id) : Message.all
        render json: messages.order_by(created_at: :desc)
    end

    # Ensures Twilio API returns a successful response before storing message
    # Else generates an error
    def create 
        message = Message.new(message_params.merge(
            direction: 'outbound', 
            status: 'sending'
        ))
        if message.save
            twilio_result = send_sms_via_twilio(message)

            if twilio_result[:success]
                message.update(
                    status: 'sent',
                    twilio_sid: twilio_result[:sid]
                )
                render json: message, status: :created
            else
                message.update(status: 'failed')
                render json: { 
                    errors: "SMS failed: #{twilio_result[:error]}"
                }, status: :unprocessable_entity
            end
        else
            render json: {
                errors: message.errors 
            }, status: :unprocessable_entity
        end
    end

    private

    def message_params
        params.require(:message).permit(
            :session_id, 
            :phone_number, 
            :message_body
        )
    end

    def send_sms_via_twilio(message)
        begin
            @client = Twilio::REST::Client.new(
                Rails.application.credentials.twilio_account_sid,
                Rails.application.credentials.twilio_auth_token
            )

            twilio_message = @client.messages
                .create(
                    to: message.phone_number,
                    body: message.message_body,
                    from: Rails.application.credentials.twilio_phone_number
                )

            Rails.logger.info "SMS request successful"
            {
                success: true,
                sid: twilio_message.sid,
                status: twilio_message.status
            }
        rescue => e
            # Return failure result
            Rails.logger.error "Twilio SMS failed: #{e.message}"
            {
                success: false,
                error: e.message
            }
        end
    end
end