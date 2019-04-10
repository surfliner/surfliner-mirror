# frozen_string_literal: true

require 'spec_helper'
require 'valkyrie/specs/shared_specs'

require_relative '../../app/models/authority'

RSpec.describe Authority do
  subject(:authority) { described_class.new }

  it_behaves_like 'a Valkyrie::Resource' do
    let(:resource_klass) { described_class }
  end

  context 'when using a concrete class' do
    let(:klass) do
      Class.new(described_class)
    end

    let(:schema_config) do
      [
        { 'prefLabel' =>
         { 'range' => 'http://www.w3.org/2008/05/skos-xl#prefLabel' } }
      ]
    end

    it 'can define a schema from a configuration' do
      expect { klass.define_schema(schema_config) }
        .to change(klass, :new)
        .to have_attribute(:pref_label)
    end
  end
end
