# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Display embedded PDFs", :clean, js: true do
  include Warden::Test::Helpers

  let!(:exhibit) do
    Spotlight::Exhibit.create(title: 'test')
  end

  let!(:pdf) do
    resource = Spotlight::Resources::Upload.new(
      data: { spotlight_upload_title_tesim: 'pdf' },
      exhibit: exhibit
    )

    image = Spotlight::FeaturedImage.new
    image.image.store!(File.open(File.join(fixture_path, 'blank.pdf')))
    resource.upload = image
    resource.save_and_index
    resource
  end

  let(:site_admin) { FactoryBot.create(:site_admin) }

  before do
    login_as site_admin
  end

  context "when viewing a PDF" do
    it "uses a direct embed" do
      visit "/spotlight/test/catalog/#{exhibit.id}-#{pdf.id}"

      expect(page).to have_selector 'embed'
      expect(page).not_to have_selector '.universal-viewer-iframe'
    end
  end
end
