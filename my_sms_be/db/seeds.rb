# Create admin user
puts "Creating admin user..."
admin_user = User.create_admin_user
puts "Admin user created: #{admin_user.user_name}"

puts "Seeding complete!"
