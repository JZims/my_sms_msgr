class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_name, type: String
  field :phone_number, type: String
  field :message_body, type: String
  field :direction, type: String
  field :status, type: String
  field :twilio_sid, type: String

  validates :user_name, presence: true
  validates :phone_number, presence: true, format: { with: /\A\+?[1-9]\d{1,14}\z/ }
  validates :message_body, presence: true, length: { maximum: 250 }
  validates :direction, inclusion: { in: %w[inbound outbound] }
  validates :status, inclusion: { in: %w[sending sent delivered failed] }

  scope :for_user, ->(user_name) { where(user_name: user_name) }

  belongs_to :user, foreign_key: :user_name, primary_key: :user_name, optional: true
end