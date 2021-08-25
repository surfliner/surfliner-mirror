# frozen_string_literal: true

require "spec_helper"
require "valkyrie/specs/shared_specs"

require_relative "../../config/environment"

RSpec.describe Concept do
  subject(:concept) { described_class.new }

  let(:resource_klass) { described_class }

  it_behaves_like "a Valkyrie::Resource"

  describe "#pref_label" do
    let(:label) { "moomin" }

    it "can set a prefLabel" do
      expect { concept.pref_label = label }
        .to change(concept, :pref_label)
        .to contain_exactly label
    end
  end

  describe "#alternate_label" do
    let(:alternate_label) { ["alternateLabel"] }

    it "can set alternateLabel" do
      expect { concept.alternate_label = alternate_label }
        .to change(concept, :alternate_label)
        .from(be_empty)
        .to alternate_label
    end
  end

  describe "#hidden_label" do
    let(:hidden_label) { ["hiddenLabel"] }

    it "can set hiddenLabel" do
      expect { concept.hidden_label = hidden_label }
        .to change(concept, :hidden_label)
        .from(be_empty)
        .to hidden_label
    end
  end

  describe "#exact_match" do
    let(:exact_match) { ["exactMatch"] }

    it "can set exactMatch" do
      expect { concept.exact_match = exact_match }
        .to change(concept, :exact_match)
        .from(be_empty)
        .to exact_match
    end
  end

  describe "#close_match" do
    let(:close_match) { ["closeMatch"] }

    it "can set closeMatch" do
      expect { concept.close_match = close_match }
        .to change(concept, :close_match)
        .from(be_empty)
        .to close_match
    end
  end

  describe "#note" do
    let(:note) { ["note"] }

    it "can set note" do
      expect { concept.note = note }
        .to change(concept, :note)
        .from(be_empty)
        .to note
    end
  end

  describe "#scope_note" do
    let(:scope_note) { "scopeNote" }

    it "can set a scope_note" do
      expect { concept.scope_note = scope_note }
        .to change(concept, :scope_note)
        .to contain_exactly scope_note
    end
  end

  describe "#editorial_note" do
    let(:editorial_note) { ["editorialNote"] }

    it "can set editorial_note" do
      expect { concept.editorial_note = editorial_note }
        .to change(concept, :editorial_note)
        .from(be_empty)
        .to editorial_note
    end
  end

  describe "#history_note" do
    let(:history_note) { ["historyNote"] }

    it "can set historyNote" do
      expect { concept.history_note = history_note }
        .to change(concept, :history_note)
        .from(be_empty)
        .to history_note
    end
  end

  describe "#definition" do
    let(:definition) { "definition" }

    it "can set a definition" do
      expect { concept.definition = definition }
        .to change(concept, :definition)
        .to contain_exactly definition
    end
  end

  describe "#scheme" do
    it "expect a scheme" do
      expect(concept.scheme).to eq described_class::SCHEMA
    end
  end

  describe "#literal_form" do
    let(:literal_form) { ["literalForm"] }

    it "can set literalForm" do
      expect { concept.literal_form = literal_form }
        .to change(concept, :literal_form)
        .from(be_empty)
        .to literal_form
    end
  end

  describe "#label_source" do
    let(:label_source) { ["labelSource"] }

    it "can set labelSource" do
      expect { concept.label_source = label_source }
        .to change(concept, :label_source)
        .from(be_empty)
        .to label_source
    end
  end

  describe "#campus" do
    let(:campus) { ["campus"] }

    it "can set campus" do
      expect { concept.campus = campus }
        .to change(concept, :campus)
        .from(be_empty)
        .to campus
    end
  end

  describe "#annotation" do
    let(:annotation) { ["annotation"] }

    it "can set annotation" do
      expect { concept.annotation = annotation }
        .to change(concept, :annotation)
        .from(be_empty)
        .to annotation
    end
  end

  describe "#identifier" do
    let(:identifier) { ["identifier"] }

    it "can set identifier" do
      expect { concept.identifier = identifier }
        .to change(concept, :identifier)
        .from(be_empty)
        .to identifier
    end
  end
end
