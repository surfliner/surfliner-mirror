# frozen_string_literal: true

require "spec_helper"

describe SurflinerSchema::HyraxLoader do
  describe "instance" do
    let(:loader_class) {
      Class.new(SurflinerSchema::HyraxLoader) do
        def self.reader_class
          Class.new(SurflinerSchema::Reader) do
            def self.config_location
              "spec/fixtures"
            end
          end
        end
      end
    }
    let(:schema) { :core_schema }
    let(:loader) { loader_class.for_schemas(schema) }

    it "#attributes_for" do
      # is there a better way of checking this?
      expect(loader.attributes_for(schema: :noop).transform_values(&:to_s)).to include(
        **{
          title: Valkyrie::Types::Array.of(Valkyrie::Types::String),
          date_modified: Valkyrie::Types::DateTime,
          date_uploaded: Valkyrie::Types::DateTime,
          depositor: Valkyrie::Types::String
        }.transform_values(&:to_s)
      )
    end

    it "#form_definitions_for" do
      expect(loader.form_definitions_for(schema: :noop).keys).to eq [:title]
      expect(loader.form_definitions_for(schema: :noop)[:title]).to include(
        required: true,
        primary: true,
        multiple: false
      )
    end

    it "#index_rules_for" do
      expect(loader.index_rules_for(schema: :noop).keys).to eq [:title_sim, :title_tesim]
      expect(loader.index_rules_for(schema: :noop)[:title_sim]).to eq :title
      expect(loader.index_rules_for(schema: :noop)[:title_tesim]).to eq :title
    end
  end
end
