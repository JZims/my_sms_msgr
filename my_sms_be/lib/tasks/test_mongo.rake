namespace :db do
  desc "Test MongoDB connection"
  task test_connection: :environment do
    puts "🔍 Testing MongoDB connection..."
    
    begin
      # Test basic connection
      result = Mongoid.default_client.command(ping: 1)
      puts "✅ MongoDB ping successful: #{result.first}"
      
      # Test database operations
      count = Message.count
      puts "✅ Message collection accessible, count: #{count}"
      
      # Test creating a simple document
      test_message = Message.new(
        content: "Connection test message",
        phone_number: "+1234567890",
        direction: "outbound",
        timestamp: Time.current
      )
      
      if test_message.valid?
        puts "✅ Message model validation passed"
      else
        puts "❌ Message model validation failed: #{test_message.errors.full_messages}"
      end
      
    rescue => e
      puts "❌ MongoDB connection test failed!"
      puts "Error: #{e.message}"
      puts "Error class: #{e.class}"
      puts "Backtrace:"
      e.backtrace.first(5).each { |line| puts "  #{line}" }
    end
  end
end
