require "rails_helper"

RSpec.describe EnvSchemaReader do
  subject(:reader) { described_class.instance }

  it "has some attributes" do
    expect(reader.attributes).not_to be_empty
  end
end
