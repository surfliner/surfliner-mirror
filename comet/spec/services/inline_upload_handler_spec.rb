# frozen_string_literal: true

require "hyrax/specs/spy_listener"

RSpec.describe InlineUploadHandler do
  subject(:service) { described_class.new(work: object) }

  let(:file) { Tempfile.new("image.jp2") }
  let(:file_2) { Tempfile.new("image2.jp2") }
  let(:object) { Hyrax.persister.save(resource: GenericObject.new) }
  let(:upload) { Hyrax::UploadedFile.create(user: user, file: file) }
  let(:uploads) { [upload, Hyrax::UploadedFile.create(user: user, file: file_2)] }
  let(:user) { User.create(email: "moomin@example.com") }

  describe "#attach" do
    let(:listener) { Hyrax::Specs::AppendingSpyListener.new }
    before { Hyrax.publisher.subscribe(listener) }
    after { Hyrax.publisher.unsubscribe(listener) }

    it "when no files are added returns uneventfully" do
      expect { service.attach }
        .not_to change { object.member_ids }
        .from be_empty
    end

    it "does not publish events" do
      service.attach

      expect(listener.object_deposited).to be_empty
      expect(listener.file_set_attached).to be_empty
    end

    context "after adding files" do
      before { service.add(files: uploads) }

      it "assigns FileSet ids synchronously" do
        expect { service.attach }
          .to change { object.member_ids }
          .to contain_exactly(an_instance_of(Valkyrie::ID),
            an_instance_of(Valkyrie::ID))
      end

      it "creates persisted filesets" do
        service.attach

        expect(Hyrax.custom_queries.find_child_filesets(resource: object))
          .to contain_exactly(be_persisted, be_persisted)
      end
    end
  end
end
