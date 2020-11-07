# frozen_string_literal: true

require 'spec_helper'
require 'support/matchers/validations'
require 'yaml'
require_relative '../../config/environment'

RSpec.describe AuthorityContract do
  subject(:contract) { described_class.new }

  it 'rejects unexpected attribute keys' do
    expect(contract.call(not_a_real_attribute: 'fake')).to be_failure
  end

  context 'with a schema configuration' do
    let(:config) { :concept }

    it 'requires a pref_label' do
      expect(described_class[config].new.call({}))
        .to have_validation_errors_on(:pref_label)
    end

    it 'does not have include presence errors for attribute that exists' do
      expect(described_class[config].new.call({ pref_label: 'exists' }))
        .not_to have_validation_errors_on(:pref_label)
    end
  end
end
