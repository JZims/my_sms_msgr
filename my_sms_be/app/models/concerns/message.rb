class Message
    include Mongoid::Document
    include Mongoid::Timestamps

    field :phone_number, type: String
    field :message_body, type: String
    field :direction, type: String
    field :status, type: String
    field :twilio_sid, type: String

    validates :phone_number, presence: true
    validates :message_body, presence: true, length {maximum: 250}
end