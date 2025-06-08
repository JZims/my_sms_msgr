# Creates outbound test messages using the FactoryBot Gem

FactoryBot.define do
    factory :message do
        session_id { "test-session-#{rand(1000)}" }
        phone_number { "+1234567890" }
        message_body { "Test message" }
        direction { "outbound" }
        status { "stored" }
    end
end
