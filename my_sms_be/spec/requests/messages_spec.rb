require 'rails_helper'

RSpec.describe "Messages API", type: :request do
  let(:session_id) { "test-session-123" }
  
  describe "POST /messages" do
    let(:valid_params) do
      {
        message: {
          session_id: session_id,
          phone_number: "+1234567890",
          message_body: "Hello from session test!"
        }
      }
    end

    before do
      # Mock Twilio credentials
      allow(Rails.application.credentials).to receive(:twilio_account_sid).and_return("test_account_sid")
      allow(Rails.application.credentials).to receive(:twilio_auth_token).and_return("test_auth_token")
      allow(Rails.application.credentials).to receive(:twilio_phone_number).and_return("+1234567890")
    end

    context "when Twilio API succeeds" do
      before do
        # Mock successful Twilio API response
        stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/test_account_sid/Messages.json")
          .to_return(
            status: 201,
            body: {
              sid: "SM123456789",
              status: "queued",
              to: "+1234567890",
              from: "+1234567890",
              body: "Hello from Twilio test!"
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "stores message with session_id in MongoDB" do
        expect {
          post "/messages", params: valid_params
        }.to change(Message, :count).by(1)

        expect(response).to have_http_status(:created)
        
        message = Message.last
        expect(message.session_id).to eq(session_id)
        expect(message.phone_number).to eq("+1234567890")
        expect(message.status).to eq("sent")
        expect(message.twilio_sid).to eq("SM123456789")
      end
    end

    context "when Twilio API fails" do
      before do
        # Mock failed Twilio API response
        stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/test_account_sid/Messages.json")
          .to_return(
            status: 400,
            body: {
              code: 21211,
              message: "The 'To' number +1234567890 is not a valid phone number.",
              more_info: "https://www.twilio.com/docs/errors/21211"
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "stores message with failed status" do
        expect {
          post "/messages", params: valid_params
        }.to change(Message, :count).by(1)

        expect(response).to have_http_status(:unprocessable_entity)
        
        message = Message.last
        expect(message.session_id).to eq(session_id)
        expect(message.phone_number).to eq("+1234567890")
        expect(message.status).to eq("failed")
        expect(message.twilio_sid).to be_nil
        
        response_body = JSON.parse(response.body)
        expect(response_body["errors"]).to include("SMS failed:")
      end
    end

    it "returns validation errors for missing session_id" do
      invalid_params = valid_params.deep_dup
      invalid_params[:message].delete(:session_id)

      post "/messages", params: invalid_params
      
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to include("session_id")
    end
  end

  describe "GET /messages" do
    let!(:session_messages) do
      create_list(:message, 2, session_id: session_id)
    end
    let!(:other_messages) do
      create_list(:message, 3, session_id: "other-session")
    end

    it "returns all messages when no session_id provided" do
      get "/messages"
      
      expect(response).to have_http_status(:ok)
      messages = JSON.parse(response.body)
      expect(messages.length).to eq(5)
    end

    it "filters messages by session_id" do
      get "/messages", params: { session_id: session_id }
      
      expect(response).to have_http_status(:ok)
      messages = JSON.parse(response.body)
      expect(messages.length).to eq(2)
      expect(messages.all? { |m| m["session_id"] == session_id }).to be true
    end

    it "returns empty array for non-existent session" do
      get "/messages", params: { session_id: "non-existent-session" }
      
      expect(response).to have_http_status(:ok)
      messages = JSON.parse(response.body)
      expect(messages).to be_empty
    end
  end
end
