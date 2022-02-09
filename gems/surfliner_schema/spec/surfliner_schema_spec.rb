# frozen_string_literal: true

require "spec_helper"

describe SurflinerSchema do
  it "has a version number" do
    expect(SurflinerSchema::VERSION).not_to be nil
  end
end
