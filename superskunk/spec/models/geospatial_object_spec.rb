require "rails_helper"

RSpec.describe GeospatialObject do
  subject(:object) { described_class.new }
  let(:title) { "Geospatial Object Title" }

  it "has some attributes" do
    object.title = title
    expect(object).to have_attributes(
      internal_resource: "GeospatialObject",
      title: [title]
    )
  end

  it "has a :mapped_to method" do
    expect(object.respond_to?(:mapped_to)).to be true
  end
end
