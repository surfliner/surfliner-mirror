# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lark::SchemaLoader do
  subject(:loader) { described_class.new }

  it "loads the required classes" do
    expect(loader.properties_for(:agent)).not_to be_empty
    expect(loader.properties_for(:concept)).not_to be_empty
    expect(loader.properties_for(:label)).not_to be_empty
  end
end
