# frozen_string_literal: true

require "spec_helper"

describe SurflinerSchema::Reader do
  describe "instance" do
    let(:reader_class) {
      Class.new(SurflinerSchema::Reader) do
        def self.config_location
          "spec/fixtures"
        end
      end
    }
    let(:schema) { :core_schema }
    let(:reader) { reader_class.new(:core_schema) }

    it "#form_options" do
      expect(reader.form_options.keys).to eq [:title]
      expect(reader.form_options[:title]).to include(
        required: true,
        primary: true,
        multiple: false
      )
    end

    it "#indices" do
      expect(reader.indices.keys).to eq [:title_sim, :title_tesim]
      expect(reader.indices[:title_sim][:name]).to eq :title
      expect(reader.indices[:title_tesim][:name]).to eq :title
    end

    it "#types" do
      # is there a better way of checking this?
      expect(reader.types.transform_values(&:to_s)).to include(
        **{
          title: Valkyrie::Types::Array.of(Valkyrie::Types::String),
          date_modified: Valkyrie::Types::DateTime,
          date_uploaded: Valkyrie::Types::DateTime,
          depositor: Valkyrie::Types::String
        }.transform_values(&:to_s)
      )
    end
  end

  describe "search_paths" do
    describe "when Rails is defined and configured" do
      before do
        stub_const("Rails", Class.new)
        allow(Rails).to receive(:root) { "/the/rails/root" }
      end

      it "uses that path" do
        expect(SurflinerSchema::Reader.search_paths).to eq ["/the/rails/root"]
      end
    end

    describe "when Hyrax is defined and configured" do
      before do
        stub_const("Rails", Class.new)
        allow(Rails).to receive(:root) { "/the/rails/root" }
        stub_const("Hyrax::Engine", Class.new)
        allow(Hyrax::Engine).to receive(:root) { "/the/hyrax/root" }
      end

      it "uses that path" do
        expect(SurflinerSchema::Reader.search_paths).to eq [
          "/the/rails/root",
          "/the/hyrax/root"
        ]
      end
    end
  end
end
