# frozen_string_literal: true

require "spec_helper"

RSpec.describe TabularParser do
  subject(:parser) { described_class.new }

  describe ".for" do
    it "resolves CSV" do
      expect(described_class.for(content_type: "text/csv"))
        .to respond_to :parse
    end

    it "raises exception for unknown formats" do
      expect { described_class.for(content_type: "application/fake") }
        .to raise_error
    end
  end

  describe "#parse" do
    it "raises NotImplementedError" do
      expect { parser.parse("/test.csv") }
        .to raise_error NotImplementedError
    end
  end
end
