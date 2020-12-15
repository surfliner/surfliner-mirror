# frozen_string_literal: true

require 'csv'
require 'rails_helper'
require 'rsolr'

RSpec.describe Importer do
  describe '#run' do
    let(:csv) do
      CSV.table(Rails.root.join(
                  'spec',
                  'fixtures',
                  'csv',
                  'minimal.csv'
                ), encoding: 'UTF-8')
    end

    let(:zipfile) do
      Pathname.new(Rails.root.join(
                     'spec',
                     'fixtures',
                     'shapefiles',
                     'gford-20140000-010004_rivers.zip'
                   )).to_s
    end

    let(:solr) do
      RSolr.connect(
        url: "http://#{ENV['SOLR_HOST']}:#{ENV['SOLR_PORT']}/solr/#{ENV['SOLR_CORE_NAME']}"
      )
    end

    it 'ingests with the correct attributes' do
      described_class.run(csv_row: csv[1], file_path: zipfile)

      beep = solr.get 'select',
                      params: { q: 'layer_slug_s:gford-20140000-010004_rivers' }

      expect(beep['response']['docs'].first['dc_rights_s']).to eq 'Restricted'
    end
  end
end
