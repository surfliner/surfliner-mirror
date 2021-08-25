# frozen_string_literal: true

require "spec_helper"
require_relative "../../config/environment"

RSpec.describe Lark::Schema do
  it "is inspectable" do
    expect(described_class.new(:concept).inspect).to include "concept"
  end
end
