# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Components", type: :system, js: true do
  let(:user) { User.create(email: "comet-admin@example.com") }

  before { login_as(user) }

  it "can attach new objects as components" do
    visit "/dashboard"
    click_on "Works"
    click_on "Add new work"

    require 'pry'; binding.pry

    fill_in("Title", with: "Parent Object")
    choose("generic_object_visibility_open")
    click_on("Save")

    click_button("Attach child")
    click_on("Attach Generic object")

    fill_in("Title", with: "Component Object")
    choose("generic_object_visibility_open")
    click_on("Save")
  end
end
