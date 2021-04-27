# frozen_string_literal: true

RSpec.describe CometObjectShowPresenter do
  subject(:presenter) { described_class.new(document, ability) }
  let(:document) { SolrDocument.new({}) }
  let(:ability) { :FAKE_ABILITY }

  describe "#member_presenters" do
    let(:document) { SolrDocument.new(member_ids_ssim: member_ids) }
    let(:member_ids) { members.map(&:id) }
    let(:members) { [] }

    it "is empty" do
      expect(presenter.member_presenters).to be_empty
    end

    context "with members" do
      let(:members) do
        [Hyrax::FileSet.new(id: "fs_1", title: ["first title"]),
          Hyrax::FileSet.new(id: "fs_2", title: ["second title"])]
      end

      before { Hyrax.index_adapter.save_all(resources: members) }

      it "lists the file sets" do
        expect(presenter.member_presenters)
          .to contain_exactly(
            have_attributes(id: "fs_1", title: ["first title"]),
            have_attributes(id: "fs_2", title: ["second title"])
          )
      end
    end
  end
end
