class Message
    include Mongoid::Document
    include Mongoid::Timestamps

    field :session_id, type: String
    field :phone_number, type: String
    field :message_body, type: String
    field :direction, type: String
    field :status, type: String
    field :twilio_sid, type: String

    validates :session_id, presence: true
    validates :phone_number, presence: true
    validates :message_body, presence: true, length: { maximum: 250 }

    # Scope for session queries, 
    scope :for_session, ->(session_id) { where(session_id: session_id)}
end