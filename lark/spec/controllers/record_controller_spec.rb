require 'spec_helper'
require_relative '../../config/environment'

RSpec.describe RecordController do
  subject(:controller) { described_class.new(params: params) }
  let(:params)         { { 'id' => 'a_fake_id' } }

  describe '#show' do
    it 'returns a rack response object' do
      expect(subject.show.first).to eq 404
    end
  end
end
