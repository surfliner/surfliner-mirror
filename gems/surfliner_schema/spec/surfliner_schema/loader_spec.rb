# frozen_string_literal: true

require "spec_helper"

describe SurflinerSchema::Loader do
  describe "search_paths" do
    describe "when Rails is defined and configured" do
      before do
        stub_const("Rails", Class.new)
        allow(Rails).to receive(:root) { "/the/rails/root" }
      end

      it "uses that path" do
        expect(SurflinerSchema::Loader.search_paths).to eq ["/the/rails/root"]
      end
    end

    describe "when Hyrax is defined and configured" do
      before do
        stub_const("Rails", Class.new)
        allow(Rails).to receive(:root) { "/the/rails/root" }
        stub_const("Hyrax::Engine", Class.new)
        allow(Hyrax::Engine).to receive(:root) { "/the/hyrax/root" }
      end

      it "uses that path" do
        expect(SurflinerSchema::Loader.search_paths).to eq [
          "/the/rails/root",
          "/the/hyrax/root"
        ]
      end
    end
  end
end
