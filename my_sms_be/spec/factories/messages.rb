FactoryBot.define do
  factory :message do
    session_id { "test-session-#{rand(1000)}" }
    phone_number { "+1234567890" }
    message_body { "Test message" }
    direction { "outbound" }
    status { "sent" }
    twilio_sid { "SM#{SecureRandom.hex(17)}" }

    trait :sending do
      status { "sending" }
      twilio_sid { nil }
    end

    trait :failed do
      status { "failed" }
      twilio_sid { nil }
    end
  end
end
