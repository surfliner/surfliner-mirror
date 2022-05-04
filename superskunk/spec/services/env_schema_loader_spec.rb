require "rails_helper"

RSpec.describe EnvSchemaLoader do
  subject(:loader) { described_class.new }

  it "loads something" do
    expect(loader.properties_for(:generic_object)).not_to be_empty
  end
end
