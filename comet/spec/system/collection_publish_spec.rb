# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish Collection", type: :system, js: true do
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

  context "with RabbitMQ", :rabbitmq do
    let(:queue_message) { [] }
    let(:connection) { Rails.application.config.rabbitmq_connection }
    let(:broker) { MessageBroker.new(connection: connection, topic: topic) }
    let(:tidewater_conf) { DiscoveryPlatform.new(:tidewater) }
    let(:topic) { tidewater_conf.topic }
    let(:tidewater_routing_key) { tidewater_conf.routing_key }

    before {
      broker.channel.queue("tidewater_queue").bind(broker.exchange, routing_key: tidewater_routing_key).subscribe do |delivery_info, metadata, payload|
        queue_message << payload
      end
    }

    after { broker.close }

    it "can publish a Collection" do
      visit "/dashboard/collections/#{collection.id}?locale=en"

      click_on "Publish collection"

      alert = page.driver.browser.switch_to.alert

      expect(alert.text).to have_content("Are you sure you want to publish the collection?")
      alert.dismiss

      publish_wait(queue_message, 0) do
        expect(queue_message.length).to eq 1
        expect(JSON.parse(queue_message.first).to_h).to include("status" => "published")
        expect(JSON.parse(queue_message.first).to_h["resourceUrl"]).to include "/#{object.id}"
      end
    end
  end
end
