require 'rails_helper'

RSpec.describe Spotlight::AddUploadsFromCSV do
  subject(:job) { described_class.new(data, exhibit, user) }

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:user) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

  before do
    ENV['IMPORT_DIR'] = Rails.root.join('spec', 'fixtures').to_s
  end

  # UCSB CSV uploads with local files instead of urls
  context 'with files in the CSV instead of URLs' do
    let(:filename) { 'blake_image.jpg' }
    let(:data) do
      [
        { 'file' => filename, 'full_title_tesim' => 'Ednah A. Rich' },
      ]
    end

    it 'creates uploaded resources for each row of data' do
      expect(Spotlight::FeaturedImage.count).to eq 0
      job.perform_now
      expect(Spotlight::FeaturedImage.where(image: 'blake_image.jpg').count).to eq 1
    end
  end
end
