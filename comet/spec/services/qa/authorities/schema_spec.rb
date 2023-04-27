# frozen_string_literal: true

require "rails_helper"

RSpec.describe Qa::Authorities::Schema do
  it "lists schema availabilities as subauthorities" do
    expect(Qa::Authorities::Schema.subauthorities).to contain_exactly(
      "generic_object",
      "geospatial_object"
    )
  end

  describe ".subauthority_for" do
    describe "with an invalid availability" do
      it "raises an error" do
        expect {
          Qa::Authorities::Schema.subauthority_for("bad_availability")
        }.to raise_error Qa::InvalidSubAuthority
      end
    end

    describe "with a valid availability" do
      let(:subauthority) {
        Qa::Authorities::Schema.subauthority_for("generic_object")
      }

      it "returns a Qa::Authorities::Schema::BaseAvailabilityAuthority subclass" do
        expect(subauthority.superclass).to be Qa::Authorities::Schema::BaseAvailabilityAuthority
        expect(subauthority.availability).to eq :generic_object
      end

      it "lists controlled properties as subauthorities" do
        expect(subauthority.subauthorities).to contain_exactly(
          "rights_statement"
        )
      end
    end
  end

  describe ".property_authority_for" do
    describe "with an invalid availability" do
      it "raises an error" do
        expect {
          Qa::Authorities::Schema.property_authority_for(
            name: "rights_statement",
            availability: "bad_availability"
          )
        }.to raise_error Qa::InvalidSubAuthority
      end
    end

    describe "with an invalid property name" do
      it "raises an error" do
        expect {
          Qa::Authorities::Schema.property_authority_for(
            name: "bad_property_name",
            availability: "generic_object"
          )
        }.to raise_error Qa::InvalidSubAuthority
      end
    end

    describe "with a valid property name and availability" do
      let(:property_authority) {
        Qa::Authorities::Schema.property_authority_for(
          name: "rights_statement",
          availability: "generic_object"
        )
      }
      let(:expected_local_value) {
        {id: "my_statement", label: "My Rights Statement", active: true, uri: "about:surfliner_schema/controlled_values/rights_statement/my_statement"}
      }

      it "returns a Qa::Authorities::Schema::BasePropertyAuthority subclass instance" do
        expect(property_authority).to be_a Qa::Authorities::Schema::BasePropertyAuthority
        expect(property_authority.availability).to eq :generic_object
        expect(property_authority.property_name).to eq :rights_statement
      end

      describe "#all" do
        it "lists the controlled values" do
          expect(property_authority.all).to contain_exactly(
            # todo: remote properties
            expected_local_value
          )
        end
      end

      describe "#find" do
        it "finds values by id" do
          expect(property_authority.find(expected_local_value[:id])).to eq expected_local_value
        end

        it "finds values by uri" do
          expect(property_authority.find(expected_local_value[:uri])).to eq expected_local_value
        end

        it "returns an empty object if nothing is found" do
          expect(property_authority.find("bad_id")).to eq({})
        end
      end

      describe "#search" do
        it "searches by display label" do
          expect(property_authority.search("My Right")).to contain_exactly(
            expected_local_value
          )
        end

        it "casefolds the query" do
          expect(property_authority.search("ﬆAtE")).to contain_exactly(
            expected_local_value
          )
        end

        it "returns an empty array if nothing is found" do
          expect(property_authority.search("bad search value")).to eq []
        end
      end
    end
  end
end
