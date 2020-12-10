# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordsController, type: :controller do
  describe '#show' do
    it 'gives a 200 status' do
      get :show, params: { id: 'fake_id' }

      expect(response.status).to eq 200
    end

    it 'assigns the client JSON as :record' do
      get :show, params: { id: 'fake_id' }

      expect(assigns(:record)).to include(id: 'fake_id')
    end
  end
end
