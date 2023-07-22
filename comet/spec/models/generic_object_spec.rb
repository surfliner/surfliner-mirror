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

  describe "date handling" do
    it "can save and index simple dates" do
      work.date_created = "1972-12-31"
      expect(work.date_created.first.object.iso8601).to eq "1972-12-31"
      expect(work.date_created.first.object.precision).to eq :day
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
      work.date_created = "1972-12"
      expect(work.date_created.first.object.iso8601).to eq "1972-12-01"
      expect(work.date_created.first.object.precision).to eq :month
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
      work.date_created = "1972"
      expect(work.date_created.first.object.iso8601).to eq "1972-01-01"
      expect(work.date_created.first.object.precision).to eq :year
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
    end

    it "can save and index simple intervals" do
      work.date_created = "1970/1972"
      expect(work.date_created.first.object.from.iso8601).to eq "1970-01-01"
      expect(work.date_created.first.object.from.precision).to eq :year
      expect(work.date_created.first.object.to.iso8601).to eq "1972-01-01"
      expect(work.date_created.first.object.to.precision).to eq :year
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
    end

    it "can save and index uncertain and approximate dates" do
      work.date_created = "1972-12-31?"
      expect(work.date_created.first.object.iso8601).to eq "1972-12-31"
      expect(work.date_created.first.object.uncertain?).to eq true
      expect(work.date_created.first.object.approximate?).to eq false
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
      work.date_created = "1972-12-31~"
      expect(work.date_created.first.object.iso8601).to eq "1972-12-31"
      expect(work.date_created.first.object.uncertain?).to eq false
      expect(work.date_created.first.object.approximate?).to eq true
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
      work.date_created = "1972-12-31%"
      expect(work.date_created.first.object.iso8601).to eq "1972-12-31"
      expect(work.date_created.first.object.uncertain?).to eq true
      expect(work.date_created.first.object.approximate?).to eq true
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
    end

    it "can save and index unspecified digits from the right" do
      work.date_created = "1972-12-XX"
      expect(work.date_created.first.object.iso8601).to eq "1972-12-01"
      expect(work.date_created.first.object.precision).to eq :day
      expect(work.date_created.first.object.unspecified?).to eq true
      expect(work.date_created.first.object.unspecified?(:day)).to eq true
      expect(work.date_created.first.object.unspecified?(:month)).to eq false
      expect(work.date_created.first.object.unspecified?(:year)).to eq false
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
      work.date_created = "1972-XX-XX"
      expect(work.date_created.first.object.iso8601).to eq "1972-01-01"
      expect(work.date_created.first.object.precision).to eq :day
      expect(work.date_created.first.object.unspecified?).to eq true
      expect(work.date_created.first.object.unspecified?(:day)).to eq true
      expect(work.date_created.first.object.unspecified?(:month)).to eq true
      expect(work.date_created.first.object.unspecified?(:year)).to eq false
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
      work.date_created = "197X-XX-XX"
      expect(work.date_created.first.object.iso8601).to eq "1970-01-01"
      expect(work.date_created.first.object.precision).to eq :day
      expect(work.date_created.first.object.unspecified?).to eq true
      expect(work.date_created.first.object.unspecified?(:day)).to eq true
      expect(work.date_created.first.object.unspecified?(:month)).to eq true
      expect(work.date_created.first.object.unspecified?(:year)).to eq true
      expect(work.date_created.first.object.unspecified.year).to eq [nil, nil, false, true]
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
      work.date_created = "19XX-XX-XX"
      expect(work.date_created.first.object.iso8601).to eq "1900-01-01"
      expect(work.date_created.first.object.precision).to eq :day
      expect(work.date_created.first.object.unspecified?).to eq true
      expect(work.date_created.first.object.unspecified?(:day)).to eq true
      expect(work.date_created.first.object.unspecified?(:month)).to eq true
      expect(work.date_created.first.object.unspecified?(:year)).to eq true
      expect(work.date_created.first.object.unspecified.year).to eq [nil, nil, true, true]
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
      work.date_created = "19XX"
      expect(work.date_created.first.object.iso8601).to eq "1900-01-01"
      expect(work.date_created.first.object.precision).to eq :year
      expect(work.date_created.first.object.unspecified?).to eq true
      expect(work.date_created.first.object.unspecified?(:day)).to eq false
      expect(work.date_created.first.object.unspecified?(:month)).to eq false
      expect(work.date_created.first.object.unspecified?(:year)).to eq true
      expect(work.date_created.first.object.unspecified.year).to eq [nil, nil, true, true]
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
    end

    # The rdf-edtf gem doesn’t support this syntax yet.
    xit "can save and index open‐ended intervals" do
      work.date_created = "1970-01-01/"
      expect(work.date_created.first.object.open?).to eq true
      expect(work.date_created.first.object.cover?(Date.today)).to eq true
      expect(work.date_created.first.object.from.iso8601).to eq "1970-01-01"
      expect(work.date_created.first.object.from.precision).to eq :day
      expect(work.date_created.first.object.to).to eq :open
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
    end

    it "can save and index uncertain and approximate intervals" do
      work.date_created = "1970?/1972~"
      expect(work.date_created.first.object.from.iso8601).to eq "1970-01-01"
      expect(work.date_created.first.object.from.uncertain?).to eq true
      expect(work.date_created.first.object.from.approximate?).to eq false
      expect(work.date_created.first.object.to.iso8601).to eq "1972-01-01"
      expect(work.date_created.first.object.to.uncertain?).to eq false
      expect(work.date_created.first.object.to.approximate?).to eq true
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
      work.date_created = "1970-01-01%/1972-12-31"
      expect(work.date_created.first.object.from.iso8601).to eq "1970-01-01"
      expect(work.date_created.first.object.from.uncertain?).to eq true
      expect(work.date_created.first.object.from.approximate?).to eq true
      expect(work.date_created.first.object.to.iso8601).to eq "1972-12-31"
      expect(work.date_created.first.object.to.uncertain?).to eq false
      expect(work.date_created.first.object.to.approximate?).to eq false
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
    end

    it "can save and index mixed precision intervals" do
      work.date_created = "1970/1972-12-31"
      expect(work.date_created.first.object.from.iso8601).to eq "1970-01-01"
      expect(work.date_created.first.object.from.precision).to eq :year
      expect(work.date_created.first.object.to.iso8601).to eq "1972-12-31"
      expect(work.date_created.first.object.to.precision).to eq :day
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
    end

    it "can save and index negative years" do
      work.date_created = "-0001"
      expect(work.date_created.first.object.iso8601).to eq "-0001-01-01"
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
    end

    it "can save and index very negative years" do
      work.date_created = "Y-10000"
      expect(work.date_created.first.object.iso8601).to eq "-10000-01-01"
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
    end

    # The rdf-edtf gem doesn’t support this syntax for days yet, only years.
    xit "can save and index one of a closed range of dates" do
      work.date_created = "[1970-01-01..1970-01-11]"
      expect(work.date_created.first.object.choice?).to eq true
      expect(work.date_created.first.object.to_a).to eq [Date.new(1970, 1, 1),
        Date.new(1970, 1, 2), Date.new(1970, 1, 3), Date.new(1970, 1, 4),
        Date.new(1970, 1, 5), Date.new(1970, 1, 6), Date.new(1970, 1, 7),
        Date.new(1970, 1, 8), Date.new(1970, 1, 9), Date.new(1970, 1, 10),
        Date.new(1970, 1, 11)]
      expect { Hyrax.persister.save(resource: work) }.not_to raise_error
      expect { Hyrax.index_adapter.save(resource: work) }.not_to raise_error
    end
  end
end
