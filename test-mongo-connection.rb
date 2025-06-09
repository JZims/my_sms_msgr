#!/usr/bin/env ruby
# Test MongoDB connection for Railway deployment

require 'mongo'

# Test the MongoDB connection with Railway credentials
mongo_uri = "mongodb://mongo:QGMfffnHJviduytdoOvWPuKNHgOTjPWR@mongodb.railway.internal:27017/my_sms_prod?authSource=admin"

puts "Testing MongoDB connection..."
puts "URI: #{mongo_uri.gsub(/:[^:@]*@/, ':***@')}"

begin
  client = Mongo::Client.new(mongo_uri)
  
  # Test the connection
  result = client.database.command(ping: 1)
  puts "✅ MongoDB connection successful!"
  puts "Ping result: #{result.first}"
  
  # List databases
  admin_db = client.use('admin').database
  dbs = admin_db.command(listDatabases: 1)
  puts "\n📊 Available databases:"
  dbs.first['databases'].each do |db|
    puts "  - #{db['name']}"
  end
  
  # Test collection operations
  puts "\n🔍 Testing collection operations..."
  db = client.database
  collections = db.collection_names
  puts "Collections in #{db.name}: #{collections}"
  
  client.close
  
rescue => e
  puts "❌ MongoDB connection failed!"
  puts "Error: #{e.message}"
  puts "Error class: #{e.class}"
  if e.respond_to?(:code)
    puts "Error code: #{e.code}"
  end
end
