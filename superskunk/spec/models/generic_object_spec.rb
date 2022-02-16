require "rails_helper"

RSpec.describe GenericObject do
  subject(:object) { described_class.new }

  it "has some attributes" do
    object.title = "abc"
    expect(object).to have_attributes(
      internal_resource: "GenericObject",
      title: ["abc"]
    )
  end
end
