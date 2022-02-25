require_relative "../lib/tidewater"

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
  identifier: "http://arXiv.org/abs/cs/0112017",
  source_iri: "http://superskunk.example.com/0112017"
)
puts "\n== loaded OAI-PMH sample item as ID - #{example_item.id}"

5.times do |i|
  item = OaiItem.create(title: "title 1#{i}", identifier: "ark://1234#{i}", creator: "surfliner #{i}", source_iri: "http://superskunk.example.com/1234#{i}")
  puts "\n== loaded item ID - #{item.id}"
end

source_id = "example:cs/0112017"
resource_uri = "http://superskunk.example.com/#{source_id}"
json_file = Rails.root.join("spec", "fixtures", "mocked_metadata_response.json")
json_data = File.read(json_file)

oai_item = Converters::OaiItemConverter.from_json(resource_uri, json_data)
Persisters::SuperskunkPersister.create_or_update(record: oai_item.with_indifferent_access)

item_source_iri = oai_item["source_iri"]
oai_sets = Converters::OaiSetConverter.from_json(json_data)

oai_sets.each do |oai_set|
  set_source_iri = oai_set["source_iri"]

  Persisters::SuperskunkSetPersister.create_or_update(record: oai_set.with_indifferent_access)
  unless Persisters::SuperskunkSetEntryPersister.entry_exists?(set_source_iri: set_source_iri, item_source_iri: item_source_iri)
    Persisters::SuperskunkSetEntryPersister.create(set_source_iri: set_source_iri, item_source_iri: item_source_iri)
  end
end
