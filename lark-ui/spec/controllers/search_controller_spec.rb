# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  describe '#search' do
    it 'gives a 200 status' do
      get :search, params: { q: 'query' }

      expect(response.status).to eq 200
    end

    it 'assigns the client JSON search results as :results' do
      get :search, params: { q: 'Comet in Moominland' }

      expect(assigns(:results)).to include({id: '1', pref_label: 'Comet in Moominland'})
    end
  end
end
