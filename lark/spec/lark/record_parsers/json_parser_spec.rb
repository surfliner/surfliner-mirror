# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lark::RecordParsers::JsonParser do
  subject(:parser) { described_class.new }

  describe "#parse" do
    let(:input) { StringIO.new('{ "key": "value" }') }

    it "parses data to a hash" do
      expect(parser.parse(input)).to eq(key: "value")
    end
  end
end
