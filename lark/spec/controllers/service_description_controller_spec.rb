# frozen_string_literal: true

require "spec_helper"
require_relative "../../config/environment"

RSpec.describe ServiceDescriptionController do
  subject(:controller) { described_class.new }

  describe "#show" do
    it "gives a 200 status" do
      expect(controller.show.first).to eq 200
    end

    it "gives a JSON response" do
      expect(controller.show[1])
        .to include "Content-Type" => "application/json"
    end

    it "provides an api service description" do
      expect(JSON.parse(controller.show.last.first))
        .to include "version" => an_instance_of(String)
    end
  end
end
