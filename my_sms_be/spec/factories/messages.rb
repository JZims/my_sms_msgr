# Creates outbound test messages using the FactoryBot Gem

FactoryBot.define do
    factory :message do
        phone_number {"+1234567890"}
        message_body { "Test message" }
        direction { "outbound" }
        status { "sending" }
  end
end
