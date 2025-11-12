# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb
require 'open-uri'

# Clear existing data
Event.destroy_all
User.destroy_all

puts "✅ Cleared existing users and events"

# Create default user
default_user = User.create!(
  email: 'kevin.a8988@gmail.com',
  password: Devise.friendly_token[0, 20],
  name: 'Kevin Arista'
)

puts "✅ Default user ready: #{default_user.email}"

# Tags pool

# Current timestamp
now = Time.zone.now

# Event data
events_data = [
  {
    title: "Midnight Movie Marathon",
    date: Date.new(2025, 11, 5),
    start_time: "23:00",
    end_time: "02:00",
    location: "Student Lounge",
    tags: ["social", "other"],
    description: "Snacks, comfy seats, and back-to-back movies all night long in the Student Lounge. Bring your friends!"
  },
  {
    title: "Campus Soccer Pickup Game",
    date: Date.new(2025, 11, 6),
    start_time: "16:00",
    end_time: "18:00",
    location: "North Field",
    tags: ["sports", "social"],
    description: "Come kick around with fellow students on the North Field! No experience needed, just fun vibes."
  },
  {
    title: "Student Potluck Dinner",
    date: Date.new(2025, 11, 8),
    start_time: "18:30",
    end_time: "21:00",
    location: "Dorm Lounge",
    tags: ["social", "cultural"],
    description: "Bring your favorite dish and sample treats from everyone else in the Dorm Lounge. The more, the merrier!"
  },
  {
    title: "K-Pop Dance Practice",
    date: Date.new(2025, 11, 10),
    start_time: "19:00",
    end_time: "20:30",
    location: "Dance Studio 2",
    tags: ["club", "social"],
    description: "Join our dance club in Dance Studio 2 to learn popular K-Pop routines—fun, energetic, and no pressure!"
  },
  {
    title: "Board Game Night",
    date: Date.new(2025, 11, 12),
    start_time: "20:00",
    end_time: "23:00",
    location: "Commons Room",
    tags: ["social", "other"],
    description: "Strategy, laughs, and snacks! Bring your favorite games or try ours in the Commons Room."
  },
  {
    title: "Open Mic Night",
    date: Date.new(2025, 11, 14),
    start_time: "21:00",
    end_time: "23:00",
    location: "Cafe Hall",
    tags: ["club", "social"],
    description: "Sing, rap, read poetry, or perform a skit! A chill space for students to showcase talents at Cafe Hall."
  },
  {
    title: "Yoga in the Quad",
    date: Date.new(2025, 11, 16),
    start_time: "08:30",
    end_time: "09:30",
    location: "Main Quad",
    tags: ["workshop", "social"],
    description: "Morning stretch and mindfulness to start your day in the Main Quad. Bring a mat and a smile!"
  },
  {
    title: "Anime Club Meeting",
    date: Date.new(2025, 11, 18),
    start_time: "17:00",
    end_time: "19:00",
    location: "Room 204, Arts Building",
    tags: ["club", "other"],
    description: "Discuss anime, vote on what to watch next, and share fan art! Snacks provided in Room 204, Arts Building."
  },
  {
    title: "Campus Volleyball Tournament",
    date: Date.new(2025, 11, 20),
    start_time: "15:00",
    end_time: "18:00",
    location: "Gymnasium Court 1",
    tags: ["sports", "club"],
    description: "Form teams or join solo! Competitive, fun, and full of school spirit in Gymnasium Court 1."
  },
  {
    title: "International Snack Exchange",
    date: Date.new(2025, 11, 22),
    start_time: "16:30",
    end_time: "18:30",
    location: "Student Center Lobby",
    tags: ["cultural", "social"],
    description: "Bring a snack from your culture and try goodies from others in the Student Center Lobby. Fun and tasty!"
  }
]

# Seed events with attached image
events_data.each do |event_data|
  event = Event.new(event_data.merge(user: default_user, created_at: now, updated_at: now))
  
  # Attach image via ActiveStorage
  file = URI.open("https://spotme.com/wp-content/uploads/2020/07/Hero-1.jpg")
  event.image.attach(io: file, filename: "event_image.jpg")
  
  event.save!
end

puts "✅ Seeded #{events_data.size} events with default image and current timestamp"
