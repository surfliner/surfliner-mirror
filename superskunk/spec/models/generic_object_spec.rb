require "rails_helper"

RSpec.describe GenericObject do
  subject(:object) { described_class.new }

  it "has some attributes" do
    expect(object).to have_attributes(title: "abc")
  end
end
