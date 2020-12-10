# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordsController, type: :controller do
  describe '#show' do
    it 'gives a 200 status' do
      get(:show)
      expect(response.status).to eq 200
    end
  end
end
