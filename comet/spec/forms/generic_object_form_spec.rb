# frozen_string_literal: true

require "rails_helper"

# autoloading fix
Hyrax::Forms::ResourceForm # rubocop:disable Lint/Void

RSpec.describe GenericObjectForm do
  let(:generic_object) { GenericObject.new }
  let(:form) { GenericObjectForm.new(generic_object) }

  describe ".definitions" do
    it "includes fields from the loaded metadata schema as keys" do
      expect(described_class.definitions.keys.map(&:to_sym)).to include :language, :title_alternative
    end
  end

  describe "#secondary_terms" do
    it "lists non‐primary fields from the loaded metadata schema" do
      expect(form.secondary_terms).to include :language, :title_alternative
    end
  end
end
