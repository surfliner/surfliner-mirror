# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ability do
  subject(:ability) { Ability.new(user) }
  let(:user) { User.find_or_create_by(email: "anyone@library.ucsb.edu") }

  describe "can?(:publish)" do
    context "for a PcdmCollection" do
      let(:collection) { Hyrax::PcdmCollection.new }

      it "is false" do
        expect(ability.can?(:publish, collection)).to be false
      end

      context "with edit access" do
        it "is true"
      end

      context "as an admin user" do
        let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

        it "is true" do
          expect(ability.can?(:publish, collection)).to be true
        end
      end
    end

    context "for a SolrDocument" do
      let(:solr_doc) { SolrDocument.new }

      it "is false" do
        expect(ability.can?(:publish, solr_doc)).to be false
      end

      context "with edit access" do
        it "is true"
      end

      context "as an admin user" do
        let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

        it "is true" do
          expect(ability.can?(:publish, solr_doc)).to be true
        end
      end
    end
  end
end
