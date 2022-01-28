# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# The following is the example record provided here:
# <http://www.openarchives.org/OAI/openarchivesprotocol.html#Record>
example_title = <<~TITLE.strip
  Using Structural Metadata to Localize Experience of Digital
               Content
TITLE
example_description_one = <<~DESCRIPTION_ONE.strip
  With the increasing technical sophistication of both
  information consumers and providers, there is increasing demand for
  more meaningful experiences of digital information. We present a
  framework that separates digital object experience, or rendering,
  from digital object storage and manipulation, so the
  rendering can be tailored to particular communities of users.
DESCRIPTION_ONE
example_description_two = <<~DESCRIPTION_TWO.strip
  Comment: 23 pages including 2 appendices,
                     8 figures
DESCRIPTION_TWO
example_item = OaiItem.create(
  title: example_title,
  creator: "Dushay, Naomi",
  subject: "Digital Libraries",
  description: [
    example_description_one,
    example_description_two
  ].join("\uFFFF"),
  date: "2001-12-14",
  type: "e-print",
  identifier: "http://arXiv.org/abs/cs/0112017"
)
puts "\n== loaded OAI-PMH sample item as ID - #{example_item.id}"

5.times do |i|
  item = OaiItem.create(title: "title 1#{i}", identifier: "ark://1234#{i}", creator: "surfliner #{i}")
  puts "\n== loaded item ID - #{item.id}"
end
