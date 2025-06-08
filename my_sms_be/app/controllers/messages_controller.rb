class MessagesController < ApplicationController
    def index
        session_id = params[:session_id]
        messages = session_id ? Message.for_session(session_id) : Message.all
        render json: messages.order_by(created_at: :desc)
    end

    def create 
        message = Message.new(message_params.merge(direction: 'outbound', status: 'stored'))
        if message.save
            render json: message, status: :created
        else
            render json: { errors: message.errors }, status: :unprocessable_entity
        end
    end

    private

    def message_params
        params.require(:message).permit(:session_id, :phone_number, :message_body)
    end
end