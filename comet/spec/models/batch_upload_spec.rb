# frozen_string_literal: true

require "rails_helper"

RSpec.describe BatchUpload do
  subject(:batch) { described_class.new }

  describe "#created_at" do
    let(:created_at) { Date.today.to_datetime }

    it "creates a timestamp" do
      expect { batch.created_at = created_at }
        .to change(batch, :created_at)
        .from(be_nil)
        .to created_at
    end
  end

  describe "#batch_id" do
    let(:batch_id) { "any_batch_id" }

    it "assigns batch_id" do
      expect { batch.batch_id = batch_id }
        .to change(batch, :batch_id)
        .from(be_nil)
        .to batch_id
    end
  end

  describe "#user_id" do
    let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

    it "assigns user_id" do
      expect { batch.user_id = user.id }
        .to change(batch, :user_id)
        .from(be_nil)
        .to user.id
    end
  end
end
