require 'spec_helper'
require 'valkyrie/specs/shared_specs'

require_relative '../../config/environment'

RSpec.describe Concept do
  subject(:concept)    { described_class.new }
  let(:resource_klass) { described_class }

  it_behaves_like 'a Valkyrie::Resource'

  describe '#pref_label' do
    let(:label) { 'moomin' }

    it 'can set a prefLabel' do
      expect { concept.pref_label = label }
        .to change { concept.pref_label }
        .to contain_exactly label
    end
  end
end
