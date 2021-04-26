# frozen_string_literal: true

RSpec.describe ARK do
  let(:ark) { "ark:/99999/real/true" }

  context "minting a new ARK" do
    subject(:minter) { described_class }

    let(:work) { Hyrax.persister.save(resource: GenericObject.new) }
    let(:id) { work.id }

    before do
      allow(Ezid::Identifier).to receive(:mint).and_return(ark)
    end

    it "returns an ARK" do
      expect(minter.mint_for(id).ark).to eq ark
    end
  end

  context "updating an existing ARK" do
    subject(:minter) { described_class }

    let(:work) do
      Hyrax.persister.save(resource: GenericObject.new(ark: ark))
    end
    let(:identifier) { instance_of(Ezid::Identifier) }

    before do
      allow(Ezid::Identifier).to receive(:find).with(work.ark).and_return(identifier)
      allow(identifier).to receive(:target=)
      allow(identifier).to receive(:save)
    end

    it "calls the ezid-client and returns the object" do
      expect(minter.update_ark(work, {target: "https://ucsb.edu"}).ark).to eq ark
    end
  end
end
