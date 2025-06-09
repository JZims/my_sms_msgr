require 'bcrypt'

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  field :user_name, type: String
  field :password_digest, type: String

  validates :user_name, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }

  has_secure_password

  # Default Admin user
  def self.create_admin_user
    find_or_create_by(user_name: "admin") do |user|
      user.password = "password123"
    end
  end

  def self.create_guest_user
    find_or_create_by(user_name: "guest") do |user|
      user.password = "password456"
    end
  end
end
