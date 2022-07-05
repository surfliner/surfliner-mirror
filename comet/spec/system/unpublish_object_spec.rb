# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Unpublish Object", type: :system, js: true do
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

  it "has no unpublish button" do
    visit main_app.hyrax_generic_object_path(id: object.id)

    expect(page).not_to have_link("Unpublish")
  end

  context "with rabbitmq", :rabbitmq do
    let(:queue_message) { [] }
    let(:connection) { Rails.application.config.rabbitmq_connection }
    let(:broker) { MessageBroker.new(connection: connection, topic: topic) }
    let(:tidewater_conf) { DiscoveryPlatform.new(:tidewater).message_route }
    let(:topic) { tidewater_conf.metadata_topic }
    let(:tidewater_routing_key) { tidewater_conf.metadata_routing_key }
    let(:url_base) { ENV.fetch("DISCOVER_PLATFORM_TIDEWATER_URL_BASE") { Rails.application.config.metadata_api_uri_base } }

    before {
      broker.channel.queue(topic).bind(broker.exchange, routing_key: tidewater_routing_key).subscribe do |delivery_info, metadata, payload|
        queue_message << payload
      end

      Hyrax.publisher.publish("collection.publish",
        collection: collection,
        user: user)
    }

    after { broker.close }

    it "has the unpublish button" do
      visit main_app.hyrax_generic_object_path(id: object.id)

      expect(page).to have_link("Unpublish")
    end

    it "can unpublish an object" do
      visit main_app.hyrax_generic_object_path(id: object.id)

      expect(page).to have_link("Tidewater")

      click_on "Unpublish"

      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to have_content("Are you sure you want to unpublish the object?")

      expect { publish_wait(queue_message, 1) { alert.accept } }
        .to change { queue_message.length }
        .by 1

      expect(page).to have_content("The unpublish object request is submitted successfully.")

      expect(JSON.parse(queue_message.pop).symbolize_keys).to include(status: "unpublished")
      expect(JSON.parse(queue_message.pop)["resourceUrl"]).to include "/#{object.id}"

      visit main_app.hyrax_generic_object_path(id: object.id)
      expect(page).not_to have_link("Unpublish")
      expect(page).not_to have_link("Tidewater")
    end
  end
end
