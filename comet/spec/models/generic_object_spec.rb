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

  # This test makes some assumptions about the format of the metadata config
  # file in order to avoid having to actually process the M3.
  it "loads metadata attributes from the provided file" do
    m3_metadata_config = YAML.safe_load(File.open(File.join(
      Rails.root,
      Rails.application.config.metadata_config_location,
      Rails.application.config.metadata_config_schemas.first.to_s + ".yaml"
    )), [], [], true)
    m3_metadata_config["properties"].each do |property|
      # Dynamically get the list of expected properties from the M3 YAML.
      next unless property["available_on"].to_a.include?("generic_object")
      property_name = property["name"]

      # Ensure each property can be changed and casts to an RDF literal.
      expect { work.public_send("#{property_name}=".to_sym, ["etaoin"]) }
        .to change { work.public_send(property_name.to_sym) }
        .to contain_exactly RDF::Literal("etaoin", datatype: property["data_type"])
    end
  end
end
