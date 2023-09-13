require "rails_helper"

RSpec.describe Bulkrax::ResourceForm do
  subject(:form) { Bulkrax::ResourceForm.for(resource) }
  let(:resource) { GenericObject.new }

  it "inherits Bulkrax::ResourceForm" do
    expect(form).to be_a described_class
  end

  it "inherits ::Forms::PcdmObjectForm" do
    expect(form).to be_a ::Forms::PcdmObjectForm
  end
end
