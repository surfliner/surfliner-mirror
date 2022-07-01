# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Routes", type: :routing do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  let(:collection_type) { Hyrax::CollectionType.create(title: "Test Collection Type") }
  let(:collection_type_gid) { collection_type.to_global_id.to_s }

  let(:collection) do
    col = Hyrax::PcdmCollection.new(title: ["Test Collection"], collection_type_gid: collection_type_gid)
    Hyrax.persister.save(resource: col)
  end

  it "redirect to hyrax/dashboard/collections#show" do
    expect(get: "/collections/#{collection.id}").to route_to(
      controller: "hyrax/dashboard/collections",
      action: "show",
      id: collection.id.to_s
    )
  end
end
