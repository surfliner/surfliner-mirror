# frozen_string_literal: true

require 'spec_helper'
require 'valkyrie/specs/shared_specs'

require_relative '../../config/environment'

RSpec.describe Agent do
  subject(:agent)    { described_class.new }

  let(:resource_klass) { described_class }

  it_behaves_like 'a Valkyrie::Resource'

  describe '#pref_label' do
    let(:label) { 'agent moomin' }

    it 'can set a prefLabel' do
      expect { agent.pref_label = label }
        .to change(agent, :pref_label)
        .to contain_exactly label
    end
  end

  describe '#alternate_label' do
    let(:alternate_label) { ['alternateLabel'] }

    it 'can set alternateLabel' do
      expect { agent.alternate_label = alternate_label }
        .to change(agent, :alternate_label)
        .from(be_empty)
        .to alternate_label
    end
  end

  describe '#hidden_label' do
    let(:hidden_label) { ['hiddenLabel'] }

    it 'can set hiddenLabel' do
      expect { agent.hidden_label = hidden_label }
        .to change(agent, :hidden_label)
        .from(be_empty)
        .to hidden_label
    end
  end

  describe '#exact_match' do
    let(:exact_match) { ['exactMatch'] }

    it 'can set exactMatch' do
      expect { agent.exact_match = exact_match }
        .to change(agent, :exact_match)
        .from(be_empty)
        .to exact_match
    end
  end

  describe '#close_match' do
    let(:close_match) { ['closeMatch'] }

    it 'can set closeMatch' do
      expect { agent.close_match = close_match }
        .to change(agent, :close_match)
        .from(be_empty)
        .to close_match
    end
  end

  describe '#note' do
    let(:note) { ['note'] }

    it 'can set note' do
      expect { agent.note = note }
        .to change(agent, :note)
        .from(be_empty)
        .to note
    end
  end

  describe '#scope_note' do
    let(:scope_note) { 'scopeNote' }

    it 'can set a scope_note' do
      expect { agent.scope_note = scope_note }
        .to change(agent, :scope_note)
        .to contain_exactly scope_note
    end
  end

  describe '#editorial_note' do
    let(:editorial_note) { ['editorialNote'] }

    it 'can set editorial_note' do
      expect { agent.editorial_note = editorial_note }
        .to change(agent, :editorial_note)
        .from(be_empty)
        .to editorial_note
    end
  end

  describe '#history_note' do
    let(:history_note) { ['historyNote'] }

    it 'can set historyNote' do
      expect { agent.history_note = history_note }
        .to change(agent, :history_note)
        .from(be_empty)
        .to history_note
    end
  end

  describe '#agent_type' do
    let(:agent_type) { 'agent type' }

    it 'can set a definition' do
      expect { agent.agent_type = agent_type }
        .to change(agent, :agent_type)
        .to contain_exactly agent_type
    end
  end

  describe '#identifier' do
    let(:identifier) { ['identifier'] }

    it 'can set identifier' do
      expect { agent.identifier = identifier }
        .to change(agent, :identifier)
        .from(be_empty)
        .to identifier
    end
  end

  describe '#begin' do
    let(:begin_date) { ['begin date'] }

    it 'can set begin date' do
      expect { agent.begin = begin_date }
        .to change(agent, :begin)
        .from(be_empty)
        .to begin_date
    end
  end

  describe '#end' do
    let(:end_date) { ['end date'] }

    it 'can set end date' do
      expect { agent.end = end_date }
        .to change(agent, :end)
        .from(be_empty)
        .to end_date
    end
  end

  describe '#family_name' do
    let(:family_name) { ['family name'] }

    it 'can set end date' do
      expect { agent.family_name = family_name }
        .to change(agent, :family_name)
        .from(be_empty)
        .to family_name
    end
  end

  describe '#given_name' do
    let(:given_name) { ['given name'] }

    it 'can set given_name' do
      expect { agent.given_name = given_name }
        .to change(agent, :given_name)
        .from(be_empty)
        .to given_name
    end
  end

  describe '#scheme' do
    it 'expect a scheme' do
      expect(agent.scheme).to eq described_class::SCHEMA
    end
  end

  describe '#literal_form' do
    let(:literal_form) { ['literalForm'] }

    it 'can set literalForm' do
      expect { agent.literal_form = literal_form }
        .to change(agent, :literal_form)
        .from(be_empty)
        .to literal_form
    end
  end

  describe '#label_source' do
    let(:label_source) { ['labelSource'] }

    it 'can set labelSource' do
      expect { agent.label_source = label_source }
        .to change(agent, :label_source)
        .from(be_empty)
        .to label_source
    end
  end

  describe '#campus' do
    let(:campus) { ['campus'] }

    it 'can set campus' do
      expect { agent.campus = campus }
        .to change(agent, :campus)
        .from(be_empty)
        .to campus
    end
  end

  describe '#annotation' do
    let(:annotation) { ['annotation'] }

    it 'can set annotation' do
      expect { agent.annotation = annotation }
        .to change(agent, :annotation)
        .from(be_empty)
        .to annotation
    end
  end
end
