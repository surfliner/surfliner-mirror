# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish Collection", type: :system, js: true, storage_adapter: :memory, metadata_adapter: :test_adapter do
  let(:connection) { Rails.application.config.rabbitmq_connection }
  let(:topic) { ENV.fetch("RABBITMQ_TOPIC", "comet.publish") }
  let(:tidewater_routing_key) { ENV.fetch("RABBITMQ_TIDEWATER_ROUTING_KEY", "comet.publish.tidewater") }

  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  let(:collection_type) { Hyrax::CollectionType.create(title: "Test Type") }
  let(:collection_type_gid) { collection_type.to_global_id.to_s }
  let(:collection) do
    col = Hyrax::PcdmCollection.new(title: ["Test Collection"], collection_type_gid: collection_type_gid)
    Hyrax.persister.save(resource: col)
  end

  let(:object) do
    obj = ::GenericObject.new(title: ["Test Object"], member_of_collection_ids: [collection.id])
    Hyrax.persister.save(resource: obj)
  end

  before {
    sign_in(user)

    Hyrax::Collections::PermissionsCreateService.create_default(collection: collection, creating_user: user)
    collection.permission_manager.read_users += [user.user_key]
    collection.permission_manager.edit_users += [user.user_key]
    collection.permission_manager.acl.save

    Hyrax.index_adapter.save(resource: collection)
    Hyrax.index_adapter.save(resource: object)
  }

  context "publish collection" do
    let(:queue_message) { [] }
    let(:broker) { MessageBroker.new(connection: connection, topic: topic) }

    before {
      broker.channel.queue("tidewater_queue").bind(broker.exchange, routing_key: tidewater_routing_key).subscribe do |delivery_info, metadata, payload|
        tidewater_queue_message << payload
      end
    }

    after { broker.close }

    it "can publish a Collection" do
      visit "/dashboard/collections/#{collection.id}?locale=en"

      click_on "Publish collection"
      expect(page).to have_content("Are you sure you want to publish the collection?")

      click_button "OK"

      expect(page).to have_content("Publish collection successfully.")

      expect(tidewater_queue_message.length).to eq 1
      expect(JSON.parse(tidewater_queue_message.first).to_h).to include("status" => "published")
      expect(JSON.parse(tidewater_queue_message.first).to_h["resourceUrl"]).to include "/#{object.id}?locale=en"
    end
  end
end
