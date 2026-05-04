# Create admin user
User.find_or_create_by!(email: "etienne@localhost") do |user|
  user.password = "Testtest1"
  user.password_confirmation = "Testtest1"
  user.role = :admin
  user.locale = "nl"
end
puts "👑 Created admin user: etienne@localhost / Testtest1"

# Create regular user
User.find_or_create_by!(email: "user@localhost") do |user|
  user.password = "Testtest1"
  user.password_confirmation = "Testtest1"
  user.role = :user
  user.locale = "en"
end
puts "👤 Created regular user: user@localhost / Testtest1"

# Optional: Load private seeds for local development.
private_seeds = Rails.root.join("db", "seeds_private.rb")

if File.exist?(private_seeds)
  puts "Loading private seeds..."
  load private_seeds
end
