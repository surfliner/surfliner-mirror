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
    let(:tidewater_conf) { DiscoveryPlatform.new(:tidewater).message_route }
    let(:topic) { tidewater_conf.metadata_topic }
    let(:tidewater_routing_key) { tidewater_conf.metadata_routing_key }
    let(:url_base) { ENV.fetch("DISCOVER_PLATFORM_TIDEWATER_URL_BASE") { Rails.application.config.metadata_api_uri_base } }
    let(:object_url) { DiscoveryPlatformPublisher.api_uri_for(object) }

    before {
      broker.channel.queue(topic).bind(broker.exchange, routing_key: tidewater_routing_key).subscribe do |delivery_info, metadata, payload|
        queue_message << payload
      end
    }

    after { broker.close }

    it "can publish a Collection" do
      visit "/dashboard/collections/#{collection.id}?locale=en"

      click_on "Publish collection"

      alert = page.driver.browser.switch_to.alert

      expect(alert.text).to have_content("Are you sure you want to publish the collection?")
      alert.accept

      publish_wait(queue_message, 0) {}

      expect(queue_message.length).to eq 1
      expect(JSON.parse(queue_message.first).to_h).to include("status" => "published")
      expect(JSON.parse(queue_message.first).to_h["resourceUrl"]).to include "/#{object.id}"
    end

    it "adds an access link to the object show pages" do
      visit "/dashboard/collections/#{collection.id}?locale=en"

      click_on "Publish collection"

      alert = page.driver.browser.switch_to.alert
      alert.accept

      publish_wait(queue_message, 0) {}

      visit "/concern/generic_objects/#{object.id}?locale=en"

      expect(page).to have_link("Tidewater", href: "#{url_base}#{ERB::Util.url_encode(object_url)}")
    end

    context "with feature collection publish enabled" do
      let(:feature_enabled) { Rails.application.config.feature_collection_publish }

      before { Rails.application.config.feature_collection_publish = true }
      after { Rails.application.config.feature_collection_publish = feature_enabled }

      it "shows the publish collection button" do
        visit "/dashboard/collections/#{collection.id}?locale=en"
        expect(page).to have_link("Publish collection")
      end
    end

    context "with feature collection publish disabled" do
      let(:feature_enabled) { Rails.application.config.feature_collection_publish }

      before { Rails.application.config.feature_collection_publish = false }
      after { Rails.application.config.feature_collection_publish = feature_enabled }

      it "hides the publish collection button" do
        visit "/dashboard/collections/#{collection.id}?locale=en"
        expect(page).not_to have_link("Publish collection")
      end
    end
  end
end
