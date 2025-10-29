# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

tags = ["Club", "Social", "Sports", "Cultural", "Workshop", "Academic", "Other"]

events = [
  {
    title: "Midnight Movie Marathon",
    date: Date.new(2025, 11, 5),
    time: "23:00",
    tags: tags.sample(2).join(", "),
    description: "Snacks, comfy seats, and back-to-back movies all night long in the Student Lounge. Bring your friends!"
  },
  {
    title: "Campus Soccer Pickup Game",
    date: Date.new(2025, 11, 6),
    time: "16:00",
    tags: tags.sample(2).join(", "),
    description: "Come kick around with fellow students on the North Field! No experience needed, just fun vibes."
  },
  {
    title: "Student Potluck Dinner",
    date: Date.new(2025, 11, 8),
    time: "18:30",
    tags: tags.sample(2).join(", "),
    description: "Bring your favorite dish and sample treats from everyone else in the Dorm Lounge. The more, the merrier!"
  },
  {
    title: "K-Pop Dance Practice",
    date: Date.new(2025, 11, 10),
    time: "19:00",
    tags: tags.sample(2).join(", "),
    description: "Join our dance club in Dance Studio 2 to learn popular K-Pop routines—fun, energetic, and no pressure!"
  },
  {
    title: "Board Game Night",
    date: Date.new(2025, 11, 12),
    time: "20:00",
    tags: tags.sample(2).join(", "),
    description: "Strategy, laughs, and snacks! Bring your favorite games or try ours in the Commons Room."
  },
  {
    title: "Open Mic Night",
    date: Date.new(2025, 11, 14),
    time: "21:00",
    tags: tags.sample(2).join(", "),
    description: "Sing, rap, read poetry, or perform a skit! A chill space for students to showcase talents at Cafe Hall."
  },
  {
    title: "Yoga in the Quad",
    date: Date.new(2025, 11, 16),
    time: "08:30",
    tags: tags.sample(2).join(", "),
    description: "Morning stretch and mindfulness to start your day in the Main Quad. Bring a mat and a smile!"
  },
  {
    title: "Anime Club Meeting",
    date: Date.new(2025, 11, 18),
    time: "17:00",
    tags: tags.sample(2).join(", "),
    description: "Discuss anime, vote on what to watch next, and share fan art! Snacks provided in Room 204, Arts Building."
  },
  {
    title: "Campus Volleyball Tournament",
    date: Date.new(2025, 11, 20),
    time: "15:00",
    tags: tags.sample(2).join(", "),
    description: "Form teams or join solo! Competitive, fun, and full of school spirit in Gymnasium Court 1."
  },
  {
    title: "International Snack Exchange",
    date: Date.new(2025, 11, 22),
    time: "16:30",
    tags: tags.sample(2).join(", "),
    description: "Bring a snack from your culture and try goodies from others in the Student Center Lobby. Fun and tasty!"
  }
]

events.each do |event|
  Event.create!(event)
end

puts "✅ Seeded 10 student-posted events with realistic tags and location pitches!"