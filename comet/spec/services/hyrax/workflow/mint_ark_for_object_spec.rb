# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::Workflow::MintARKForObject do
  let(:admin_set) do
    Hyrax.query_service.find_all_of_model(model: Hyrax::AdministrativeSet)
      .find { |p| p.title.include?("Test Project") }
  end
  let(:work) do
    Hyrax.persister.save(resource: GenericObject.new(title: "friend", admin_set_id: admin_set.id))
  end

  # let(:work) { FactoryBot.valkyrie_create(:hyrax_work) }
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  subject(:workflow_method) { described_class }

  before do
    setup_workflow_for(user)

    allow(Ezid::Identifier).to receive(:mint).and_return("ark:/99999/fk4test")
  end

  describe ".call" do
    it "sets the ARK property" do
      expect { workflow_method.call(target: work) }
        .to change { Hyrax.query_service.find_by(id: work.id).ark }
        .from(be_blank)
        .to("ark:/99999/fk4test")
    end
  end
end
