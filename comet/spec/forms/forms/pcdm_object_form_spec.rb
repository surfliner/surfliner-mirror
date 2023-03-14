# frozen_string_literal: true

require "rails_helper"

RSpec.describe Forms::PcdmObjectForm do
  let(:generic_object) { GenericObject.new }
  let(:form) { Hyrax::Forms::ResourceForm.for(generic_object) }

  it "is a Forms::PcdmObjectForm" do
    expect(form).to be_a Forms::PcdmObjectForm
  end

  describe ".definitions" do
    it "includes fields from the loaded metadata schema as keys" do
      expect(form.class.definitions.keys.map(&:to_sym)).to include :title_alternative
    end
  end

  describe "#secondary_terms" do
    it "lists non‐primary fields from the loaded metadata schema" do
      expect(form.secondary_terms).to include :title_alternative
    end
  end

  describe "#sync" do
    context "when setting an embargo" do
      let(:params) do
        {title: ["Object Under Embargo"],
         embargo_release_date: Date.tomorrow.to_s,
         visibility: "embargo",
         visibility_after_embargo: "open",
         visibility_during_embargo: "restricted"}
      end

      it "builds an embargo" do
        form.validate(params)

        expect { form.sync }
          .to change { generic_object.embargo }
          .to have_attributes(embargo_release_date: Date.tomorrow.to_s,
            visibility_after_embargo: "open",
            visibility_during_embargo: "restricted")
      end

      it 'sets visibility to "during" value' do
        form.validate(params)

        expect(form.visibility).to eq "restricted"
      end
    end

    context "when setting a lease" do
      let(:params) do
        {title: ["Object Under Lease"],
         lease_expiration_date: Date.tomorrow.to_s,
         visibility: "lease",
         visibility_after_lease: "restricted",
         visibility_during_lease: "open"}
      end

      it "builds an embargo" do
        form.validate(params)

        expect { form.sync }
          .to change { generic_object.lease }
          .to have_attributes(lease_expiration_date: Date.tomorrow.to_s)
      end

      it 'sets visibility to "during" value' do
        form.validate(params)
        expect(form.visibility).to eq "open"
      end
    end
  end
end
