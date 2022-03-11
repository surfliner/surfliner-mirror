require "rails_helper"

RSpec.describe EnvSchemaLoader do
  subject(:loader) { described_class.instance }

  it "loads something" do
    expect(loader.load_all).not_to be_empty
  end
end
