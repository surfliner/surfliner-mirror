# frozen_string_literal: true

require "spec_helper"
require_relative "../../config/environment"

RSpec.describe ServiceDescription do
  subject(:service_description) { described_class.new }

  describe "#to_json" do
    it "gives a json representation" do
      expect { JSON.parse(service_description.to_json) }.not_to raise_error
    end
  end

  describe "#version" do
    it "gives an api version number" do
      expect(service_description.version).to match(/\d+\.\d+\.\d+/)
    end
  end
end
