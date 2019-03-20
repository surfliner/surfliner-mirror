# frozen_string_literal: true

require 'spec_helper'
require 'lark/client/connection'

RSpec.describe Lark::Client::Connection do
  subject(:connection) { described_class.new(server_url: 'http://example.com') }

  describe 'initializing' do
    it 'casts String to a URI' do
      expect(connection.server_url).to eq URI('http://example.com/')
    end

    it 'accepts a URI' do
      uri = URI('http://example.com')

      expect(described_class.new(server_url: uri).server_url).to eq uri
    end
  end

  describe '#create' do
    it do
      connection.create(data: '{ pref_label: "Moomin" }')
    end
  end
end
