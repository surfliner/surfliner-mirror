require "rails_helper"

RSpec.describe OaiItem do
  it "has a title" do
    subject.title = "foo"
    expect(subject.title).to eq "foo"
  end
end
