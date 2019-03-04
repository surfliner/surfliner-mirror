# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Display embedded PDFs", :clean, type: :system, js: true do
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

  let(:site_admin) { FactoryBot.create(:omniauth_site_admin) }

  before do
    omniauth_setup_shibboleth_for(site_admin)
    sign_in
  end

  context "when viewing a PDF" do
    it "uses a direct embed" do
      visit "/spotlight/test/catalog/#{exhibit.id}-#{pdf.id}"

      expect(page).to have_selector 'embed'
      expect(page).not_to have_selector '.universal-viewer-iframe'
    end
  end
end
