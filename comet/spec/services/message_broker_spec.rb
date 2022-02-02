# frozen_string_literal: true

require "rails_helper"

RSpec.describe MessageBroker, :rabbitmq do
  let(:broker) { described_class.new(connection: connection, topic: topic) }
  let(:tidewater) { described_class.new(connection: connection, topic: topic) }
  let(:shoreline) { described_class.new(connection: connection, topic: topic) }

  let(:connection) { Rails.application.config.rabbitmq_connection }
  let(:topic) { ENV.fetch("RABBITMQ_TOPIC", "surfliner.metadata") }
  let(:tidewater_routing_key) { ENV.fetch("RABBITMQ_TIDEWATER_ROUTING_KEY", "surfliner.metadata.tidewater") }
  let(:shoreline_routing_key) { ENV.fetch("RABBITMQ_SHORELINE_ROUTING_KEY", "surfliner.metadata.shoreline") }

  let(:tidewater_payload_a) { {resourceUrl: "https://tidewaterurl/to/resource/a", status: "published"} }
  let(:tidewater_payload_b) { {resourceUrl: "https://tidewaterurl/to/resource/b", status: "modified"} }
  let(:tidewater_payload_c) { {resourceUrl: "https://tidewaterurl/to/resource/c", status: "deleted"} }

  let(:shoreline_payload_a) { {resourceUrl: "https://shoreline/url/to/resource/a", status: "published"} }
  let(:shoreline_payload_b) { {resourceUrl: "https://shoreline/url/to/resource/b", status: "modified"} }
  let(:shoreline_payload_c) { {resourceUrl: "https://shoreline/url/to/resource/c", status: "deleted"} }

  before {
    @tidewater_queue_message = []
    @shoreline_queue_message = []

    tidewater.channel.queue("tidewater_queue").bind(tidewater.exchange, routing_key: tidewater_routing_key).subscribe do |delivery_info, metadata, payload|
      @tidewater_queue_message << payload
    end
    shoreline.channel.queue("shoreline_queue").bind(shoreline.exchange, routing_key: shoreline_routing_key).subscribe do |delivery_info, metadata, payload|
      @shoreline_queue_message << payload
    end
  }

  after {
    broker.close
    tidewater.close
    shoreline.close
  }

  it "routing message to tidewater" do
    broker.publish(payload: tidewater_payload_a.to_json, routing_key: tidewater_routing_key)

    begin_time = Time.now
    sleep 1.seconds and puts "Waiting on receiving message " until Time.now > (begin_time + 2) || @tidewater_queue_message.length > 0

    expect(@tidewater_queue_message.length).to eq 1
    expect(@tidewater_queue_message[0]).to eq tidewater_payload_a.to_json
  end

  it "routing message to shoreline" do
    broker.publish(payload: shoreline_payload_a.to_json, routing_key: shoreline_routing_key)

    begin_time = Time.now
    sleep 1.seconds and puts "Waiting on receiving message " until Time.now > (begin_time + 2) || @shoreline_queue_message.length > 0

    expect(@shoreline_queue_message.length).to eq 1
    expect(@shoreline_queue_message[0]).to eq shoreline_payload_a.to_json
  end

  it "routing messages to both tidewater and shoreline" do
    broker.publish(payload: tidewater_payload_a.to_json, routing_key: tidewater_routing_key)
    broker.publish(payload: tidewater_payload_b.to_json, routing_key: tidewater_routing_key)
    broker.publish(payload: tidewater_payload_c.to_json, routing_key: tidewater_routing_key)

    broker.publish(payload: shoreline_payload_a.to_json, routing_key: shoreline_routing_key)
    broker.publish(payload: shoreline_payload_b.to_json, routing_key: shoreline_routing_key)
    broker.publish(payload: shoreline_payload_c.to_json, routing_key: shoreline_routing_key)

    begin_time = Time.now
    sleep 1.seconds and puts "Waiting on receiving message " until Time.now > (begin_time + 5) || @shoreline_queue_message.length >= 3

    expect(@tidewater_queue_message.length).to eq 3
    expect(@tidewater_queue_message[0]).to eq tidewater_payload_a.to_json
    expect(@tidewater_queue_message[1]).to eq tidewater_payload_b.to_json
    expect(@tidewater_queue_message[2]).to eq tidewater_payload_c.to_json

    expect(@shoreline_queue_message.length).to eq 3
    expect(@shoreline_queue_message[0]).to eq shoreline_payload_a.to_json
    expect(@shoreline_queue_message[1]).to eq shoreline_payload_b.to_json
    expect(@shoreline_queue_message[2]).to eq shoreline_payload_c.to_json
  end
end
