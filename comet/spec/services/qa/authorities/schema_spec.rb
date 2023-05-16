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
        expect(subauthority.subauthorities).to include(
          "rights_statement"
        )
      end

      it "does not list non‐controlled properties as subauthorities" do
        expect(subauthority.subauthorities).not_to include(
          "title_alternative"
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
      let(:local_values) {
        {my_statement: {id: "my_statement", label: "My Rights Statement", active: true, uri: "about:surfliner_schema/controlled_values/rights_statement/my_statement"},
         my_other_statement: {id: "my_other_statement", label: "My Other Rights Statement", active: true, uri: "about:surfliner_schema/controlled_values/rights_statement/my_other_statement"}}
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
            *local_values.values
          )
        end
      end

      describe "#find" do
        let(:local_value) { local_values[:my_statement] }

        it "finds values by id" do
          expect(property_authority.find(local_value[:id])).to eq local_value
        end

        it "finds values by uri" do
          expect(property_authority.find(local_value[:uri])).to eq local_value
        end

        it "returns an empty object if nothing is found" do
          expect(property_authority.find("bad_id")).to eq({})
        end
      end

      describe "#search" do
        let(:local_value) { local_values[:my_statement] }

        it "searches by display label" do
          expect(property_authority.search("My Right")).to include(local_value)
        end

        it "casefolds the query" do
          expect(property_authority.search("ﬆAtE")).to include(local_value)
        end

        it "returns an empty array if nothing is found" do
          expect(property_authority.search("bad search value")).to eq []
        end
      end
    end
  end
end
