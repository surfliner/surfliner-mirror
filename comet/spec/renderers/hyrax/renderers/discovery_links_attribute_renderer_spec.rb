# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::Renderers::DiscoveryLinksAttributeRenderer do
  let(:field) { :discovery_links }
  let(:renderer) { described_class.new(field, [["Tidewater", "http://tidewater.example.com/abc"].to_s]) }

  describe "#attribute_to_html" do
    subject { Nokogiri::HTML(renderer.render) }

    let(:expected) { Nokogiri::HTML(tr_content) }

    let(:tr_content) do
      "<tr><th>Discovery links</th>" \
       "<td><ul class='tabular'>" \
       "<li class=\"attribute attribute-discovery_links\"><a href=\"http://tidewater.example.com/abc\">Tidewater</a></li>" \
       "</ul></td></tr>"
    end

    it { expect(subject).to be_equivalent_to(expected) }
  end
end
