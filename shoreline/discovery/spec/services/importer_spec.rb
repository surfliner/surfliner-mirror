# frozen_string_literal: true

require 'csv'
require 'rails_helper'
require 'rsolr'

RSpec.describe Importer do
  describe '#publish_to_geoblacklight' do
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

    let(:metadata) do
      described_class.hash_from_xml(file: zipfile)
                     .merge(described_class.hash_from_csv(row: csv[1]))
                     .merge({ layer_geom_type_s: 'fake' })
                     .merge(described_class::EXTRA_FIELDS).reject { |_k, v| v.blank? }
    end

    it 'ingests with the correct attributes' do
      described_class.publish_to_geoblacklight(metadata: metadata)

      beep = solr.get 'select',
                      params: { q: 'layer_slug_s:gford-20140000-010004_rivers' }

      expect(beep['response']['docs'].first['dc_rights_s']).to eq 'Restricted'
    end
  end
end
