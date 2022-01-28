# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

5.times do |i|
  item = OaiItem.create(title: "title 1#{i}", identifier: "ark://1234#{i}", creator: "surfliner #{i}")
  puts "\n== loaded item ID - #{item.id}"
end