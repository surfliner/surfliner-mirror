# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'records/show.html.erb', type: :view do
  before do
    assign(:record, { pref_label: 'Finn Family Moomintroll', id: 'moomin' })
  end

  it 'renders the pref_label' do
    expect(render).to include 'Finn Family Moomintroll'
  end
end
