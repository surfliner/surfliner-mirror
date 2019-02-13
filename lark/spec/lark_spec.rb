require 'spec_helper'
require_relative '../lib/lark'

RSpec.describe Lark do
  describe 'configuration' do
    it 'has an index adapter' do
      expect(Lark.config.index_adapter).to be_a Symbol
    end

    it 'can change the index adapter' do
      expect { Lark.config.index_adapter = :moomin }
        .to change { Lark.config.index_adapter }
        .to :moomin
    end
  end
end
