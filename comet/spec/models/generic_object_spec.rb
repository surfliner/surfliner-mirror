# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource GenericObject`
require "rails_helper"
require "hyrax/specs/shared_specs/hydra_works"

RSpec.describe GenericObject do
  subject(:work) { described_class.new }

  it_behaves_like "a Hyrax::Work"

  it "round trips the work" do
    work.title = "Comet in Moominland"
    id = Hyrax.persister.save(resource: work).id

    expect(Hyrax.query_service.find_by(id: id))
      .to have_attributes(title: contain_exactly("Comet in Moominland"))
  end
end
