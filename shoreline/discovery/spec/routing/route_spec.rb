# frozen_string_literal: true

RSpec.describe "Routes", type: :routing do
  describe "Contact Form" do
    it "routes to new" do
      expect(get: "/contact")
        .to route_to(controller: "contact_form", action: "new")
    end

    it "routes to create" do
      expect(post: "/contact")
        .to route_to(controller: "contact_form", action: "create")
    end
  end
end
