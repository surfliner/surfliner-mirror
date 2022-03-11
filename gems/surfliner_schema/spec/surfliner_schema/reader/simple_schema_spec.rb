# frozen_string_literal: true

require "spec_helper"

describe SurflinerSchema::Reader::SimpleSchema do
  describe "instance" do
    let(:loader_class) {
      Class.new(SurflinerSchema::Loader) do
        def self.config_location
          "spec/fixtures"
        end
      end
    }
    let(:schema) { :core_schema }
    let(:reader) { loader_class.instance.load(:core_schema) }

    it "#form_options" do
      expect(reader.form_options.keys).to eq [:title]
      expect(reader.form_options[:title]).to include(
        required: true,
        primary: true,
        multiple: false
      )
    end

    it "#indices" do
      expect(reader.indices.keys).to contain_exactly(
        :title_sim,
        :title_tsim,
        :title_tesim
      )
      expect(reader.indices[:title_sim].name).to eq :title
      expect(reader.indices[:title_tsim].name).to eq :title
      expect(reader.indices[:title_tesim].name).to eq :title
    end
  end
end
