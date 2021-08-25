# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lark::RecordParser do
  subject(:parser) { described_class.new }

  describe ".for" do
    it "resolves json" do
      expect(described_class.for(content_type: "application/json"))
        .to respond_to :parse
    end

    it "raises UnsupportedMediaType for unknown formats" do
      expect { described_class.for(content_type: "application/fake") }
        .to raise_error Lark::UnsupportedMediaType
    end
  end

  describe "#parse" do
    it "raises NotImplementedError" do
      expect { parser.parse(StringIO.new) }
        .to raise_error NotImplementedError
    end
  end
end
