# frozen_string_literal: true

require "spec_helper"

RSpec.describe ApplicationController do
  subject(:controller) { Class.new(described_class).new(request: request) }

  let(:body) { StringIO.new("") }
  let(:headers) { {} }
  let(:request) { instance_double(Rack::Request, body: body, env: headers) }

  describe "#raise_error_for" do
    it "raises a generic (server-side) request error for unknown failures" do
      expect { controller.send(:raise_error_for, reason: :MADE_UP_REASON) }
        .to raise_error Lark::RequestError, /Unknown/
    end

    it "raises a generic (server-side) request error for :minter_failed" do
      expect { controller.send(:raise_error_for, reason: :minter_failed) }
        .to raise_error Lark::RequestError
    end

    it "raises a BadRequest for :validation_failures" do
      expect { controller.send(:raise_error_for, reason: :invalid_attributes) }
        .to raise_error Lark::BadRequest
    end

    it "raises a BadRequest for :unknown_attribute" do
      expect { controller.send(:raise_error_for, reason: :unknown_attribute) }
        .to raise_error Lark::BadRequest
    end
  end
end
