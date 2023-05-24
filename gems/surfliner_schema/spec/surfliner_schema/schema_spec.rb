# frozen_string_literal: true

require "spec_helper"

RSpec.describe SurflinerSchema do
  describe "::Schema()" do
    let(:model_class) do
      Class.new(Valkyrie::Resource)
    end

    let(:reader_class) do
      Class.new(SurflinerSchema::Reader) do
        def properties(availability:)
          return unless availability == :my_availability
          {
            test_field: SurflinerSchema::Property.new(
              name: :test_field,
              display_label: "Test Field",
              available_on: [:my_availability],
              data_type: RDF::XSD.dateTime
            ),
            plain_field: SurflinerSchema::Property.new(
              name: :plain_field,
              display_label: "Plain Field",
              available_on: [:my_availability],
              data_type: RDF::RDFV.PlainLiteral
            ),
            tagged_field: SurflinerSchema::Property.new(
              name: :tagged_field,
              display_label: "Language‐Tagged Field",
              available_on: [:my_availability],
              data_type: RDF::RDFV.langString
            ),
            language_field: SurflinerSchema::Property.new(
              name: :language_field,
              display_label: "Language Field",
              available_on: [:my_availability],
              data_type: RDF::XSD.language
            )
          }
        end
      end
    end
    let(:loader) { SurflinerSchema::Loader.for_readers([reader_class.new]) }

    it "builds a schema module" do
      expect(described_class.Schema(:my_availability, loader: loader))
        .to be_a described_class::Schema
    end

    it "adds attributes when included" do
      expect { model_class.include(described_class.Schema(:my_availability, loader: loader)) }
        .to change { model_class.attribute_names }
        .to include(:test_field)
    end

    describe "when casting RDF literals" do
      it "correctly casts ordinary RDF literals" do
        # The cast must preserve the lexical value of the literal while changing
        # the datatype.
        dry_type = described_class.Schema(:my_availability, loader: loader).attributes[:test_field]
        expect(
          dry_type[RDF::Literal("🆖", datatype: RDF::XSD.date)]
        ).to contain_exactly RDF::Literal("🆖", datatype: RDF::XSD.dateTime)
      end

      it "correctly casts RDF literals to xsd:language" do
        dry_type = described_class.Schema(:my_availability, loader: loader).attributes[:language_field]
        expect(
          dry_type[RDF::Literal("CYM")]
        ).to contain_exactly RDF::Literal("cy", datatype: RDF::XSD.language)
        expect( # does not modify tags outside of ISO
          dry_type[RDF::Literal("sjn-Teng")]
        ).to contain_exactly RDF::Literal("sjn-Teng", datatype: RDF::XSD.language)
      end

      it "correctly casts plain RDF literals with no language" do
        dry_type = described_class.Schema(:my_availability, loader: loader).attributes[:plain_field]
        expect(
          dry_type[RDF::Literal("plain")]
        ).to contain_exactly RDF::Literal("plain", datatype: RDF::XSD.string)
      end

      it "correctly casts language‐tagged RDF literals" do
        dry_type = described_class.Schema(:my_availability, loader: loader).attributes[:plain_field]
        expect(
          dry_type[RDF::Literal("1234", language: "zxx")]
        ).to contain_exactly RDF::Literal("1234", language: "zxx")
      end
    end

    describe "when casting strings" do
      it "correctly casts values to xsd:language" do
        dry_type = described_class.Schema(:my_availability, loader: loader).attributes[:language_field]
        expect(
          dry_type["WEL"]
        ).to contain_exactly RDF::Literal("cy", datatype: RDF::XSD.language)
        expect( # does not modify tags outside of ISO
          dry_type[RDF::Literal("en-CA")]
        ).to contain_exactly RDF::Literal("en-CA", datatype: RDF::XSD.language)
      end

      it "casts to xsd:string for plain literals" do
        dry_type = described_class.Schema(:my_availability, loader: loader).attributes[:plain_field]
        expect(
          dry_type["plain"]
        ).to contain_exactly RDF::Literal("plain", datatype: RDF::XSD.string)
      end

      it "tags with 'und' when casting to rdf:langString" do
        dry_type = described_class.Schema(:my_availability, loader: loader).attributes[:tagged_field]
        expect(
          dry_type["plain"]
        ).to contain_exactly RDF::Literal("plain", language: "und")
      end
    end
  end
end

RSpec.describe SurflinerSchema::Schema do
  subject(:schema_module) { SurflinerSchema::Schema.new(:my_availability, loader: double) }

  describe "#inspect" do
    it "has a readable value" do
      expect(schema_module.inspect)
        .to eq described_class.name + "(my_availability)"
    end
  end
end
