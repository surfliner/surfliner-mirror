# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../app/models/schema/agent'

RSpec.describe Schema::Agent do
  before do
    class TestAgent < Valkyrie::Resource
      include Schema::Agent
    end
  end

  after do
    Object.send(:remove_const, :TestAgent)
  end

  context 'with a new TestAgent Class' do
    subject(:resource) { TestAgent.new }

    let(:url_base) { 'http://example.com/' }

    before do
      resource.pref_label = 'pref label'
      resource.alternate_label = 'alternate label'
      resource.hidden_label = 'hidden label'
      resource.exact_match = "#{url_base}exact_match"
      resource.close_match = "#{url_base}close_match"
      resource.note = 'note'
      resource.scope_note = 'scope note'
      resource.editorial_note = 'editorial note'
      resource.history_note = 'history note'
      resource.scheme = "#{url_base}schema"
      resource.literal_form = 'literal form'
      resource.agent_type = 'agent type'
      resource.identifier = 'identifier'
      resource.begin = 'begin date'
      resource.end = 'end date'
      resource.family_name = 'family name'
      resource.given_name = 'given name'
      resource.label_source = "#{url_base}label_source"
      resource.campus = 'campus'
      resource.annotation = 'annotation'
    end

    it 'a Valkyrie::Resource type' do
      expect(resource).to be_a(Valkyrie::Resource)
    end

    it 'mixes in the module' do
      expect(resource.class.ancestors).to include(described_class)
    end

    it 'has pref_label for subclass instances' do
      expect(resource.pref_label).to include 'pref label'
    end

    it 'has alternate_label for subclass instances' do
      expect(resource.alternate_label).to include 'alternate label'
    end

    it 'has hidden_label for subclass instances' do
      expect(resource.hidden_label).to include 'hidden label'
    end

    it 'has exact_match for subclass instances' do
      expect(resource.exact_match).to include "#{url_base}exact_match"
    end

    it 'has close_match for subclass instances' do
      expect(resource.close_match).to include "#{url_base}close_match"
    end

    it 'has note for subclass instances' do
      expect(resource.note).to include 'note'
    end

    it 'has scope_note for subclass instances' do
      expect(resource.scope_note).to include 'scope note'
    end

    it 'has editorial_note for subclass instances' do
      expect(resource.editorial_note).to include 'editorial note'
    end

    it 'has history_note for subclass instances' do
      expect(resource.history_note).to include 'history note'
    end

    it 'has scheme for subclass instances' do
      expect(resource.scheme).to include "#{url_base}schema"
    end

    it 'has literal_form for subclass instances' do
      expect(resource.literal_form).to include 'literal form'
    end

    it 'has agent type for subclass instances' do
      expect(resource.agent_type).to include 'agent type'
    end

    it 'has identifier for subclass instances' do
      expect(resource.identifier).to include 'identifier'
    end

    it 'has label_source for subclass instances' do
      expect(resource.label_source).to include "#{url_base}label_source"
    end

    it 'has campus for subclass instances' do
      expect(resource.campus).to include 'campus'
    end

    it 'has annotation for subclass instances' do
      expect(resource.annotation).to include 'annotation'
    end

    it 'has begin date for subclass instances' do
      expect(resource.begin).to include 'begin date'
    end

    it 'has end date for subclass instances' do
      expect(resource.end).to include 'end date'
    end

    it 'has family name for subclass instances' do
      expect(resource.family_name).to include 'family name'
    end

    it 'has given name for subclass instances' do
      expect(resource.given_name).to include 'given name'
    end
  end
end
