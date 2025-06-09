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
  validates :phone_number, presence: true, format: { 
    with: /\A\+?[1-9]\d{1,14}\z/, 
    message: "must be a valid phone number" 
  }
  validates :message_body, presence: true, length: { maximum: 250 }
  validates :direction, inclusion: { in: %w[inbound outbound] }
  validates :status, inclusion: { in: %w[sending sent failed delivered] }

  scope :for_session, ->(session_id) { where(session_id: session_id) }
end