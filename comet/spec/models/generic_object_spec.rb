# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource GenericObject`
require "rails_helper"
require "hyrax/specs/shared_specs/hydra_works"

RSpec.describe GenericObject do
  subject(:work) { described_class.new }

  it_behaves_like "a Hyrax::Work"

  it "round trips the work" do
    work.title = "Comet in Moominland"
    id = Hyrax.persister.save(resource: work).id

    expect(Hyrax.query_service.find_by(id: id))
      .to have_attributes(title: contain_exactly("Comet in Moominland"))
  end

  it "loads metadata attributes from the provided file" do
    m3_metadata_config = YAML.safe_load(File.open(File.join(Rails.root, "spec/fixtures/metadata/m3-metadata.yml")))
    m3_metadata_config["properties"].keys.each do |property|
      # Dynamically get the list of expected properties from the M3 YAML.
      next unless m3_metadata_config.dig("properties", property, "available_on", "class").to_a.include?("generic_object")

      # Ensure each property can be changed and casts to an RDF literal.
      expect { work.public_send("#{property}=".to_sym, ["etaoin"]) }
        .to change { work.public_send(property) }
        .to contain_exactly RDF::Literal.new("etaoin")
    end
  end
end
