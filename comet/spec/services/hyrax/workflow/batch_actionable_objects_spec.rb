# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::Workflow::BatchActionableObjects do
  subject(:service) { described_class.new(user: user) }
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  describe "#each" do
    let(:q) { "" }
    let(:batch_id) { "" }

    it "is empty by default" do
      expect(service.each).to be_none
    end

    context "with objects in workflow" do
      let(:admin_set) do
        Hyrax.query_service.find_all_of_model(model: Hyrax::AdministrativeSet)
          .find { |p| p.title.include?("Test Project") }
      end
      let(:objects) do
        [Hyrax.persister.save(resource: GenericObject.new(title: "Test Object A", admin_set_id: admin_set.id)),
          Hyrax.persister.save(resource: GenericObject.new(title: "Test Object B", admin_set_id: admin_set.id))]
      end

      before do
        setup_workflow_for(user)
        objects.each { |o| Hyrax::Workflow::WorkflowFactory.create(o, {}, user) }
      end

      context "and user available actions" do
        it "lists the objects" do
          expect(service.map(&:id)).to contain_exactly(*objects.map(&:id))
        end

        it "includes the workflow states" do
          expect(service.map(&:workflow_state))
            .to contain_exactly("in_review", "in_review")
        end
      end

      context "and keyword search" do
        let(:q) { "Test Object B" }
        let(:batch_id) { "" }

        it "lists the objects" do
          expect(service.map(&:id)).to contain_exactly(objects[1].id)
        end

        it "includes the workflow states" do
          expect(service.map(&:workflow_state)).to contain_exactly("in_review")
        end
      end
    end
  end
end
