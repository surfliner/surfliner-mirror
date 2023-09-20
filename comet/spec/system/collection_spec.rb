# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Collections", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  let(:collection) do
    FactoryBot.valkyrie_create(:collection,
      :with_permission_template,
      title: ["Test Collection"],
      edit_users: [user],
      read_users: [user],
      user: user)
  end

  before { sign_in user }

  it "can create a new collection and add object" do
    Hyrax::CollectionType.create(title: "Spec Type")

    visit "/admin/collection_types"
    click_on "Create new collection type"
    fill_in("Type name", with: "Curated Collection")
    click_on "Save"

    visit "/dashboard"
    click_on "Collections"
    find("#add-new-collection-button").click
    within("div#collectiontypes-to-create") do
      choose("Spec Type")
      click_on("Create collection")
    end
    fill_in("Title", with: "System Spec Collection")

    expect { click_on("Save") }
      .to change { Hyrax.query_service.count_all_of_model(model: Hyrax::PcdmCollection) }
      .by 1

    expect(page).to have_content("Collection was successfully created.")
    expect(page).to have_content("System Spec Collection")

    # TODO: teach collection controller to use a new non-Solr presenter
    click_on("Display all details of System Spec Collection")
    expect(page).to have_content("System Spec Collection")
  end

  context "with edit access on an existing collection" do
    it "can destroy the collection" do
      visit "/dashboard/collections/#{collection.id}"
      accept_alert { click_on "Delete collection" }

      expect(page).to have_content(" successfully deleted")
      expect { Hyrax.query_service.find_by(id: collection.id) }
        .to raise_error Valkyrie::Persistence::ObjectNotFoundError
    end

    it "can edit a collection" do
      visit "/dashboard/collections/#{collection.id}"
      click_on "Edit collection"

      fill_in("Title", with: "Updated Collection")
      click_on "Save changes"

      reloaded = Hyrax.query_service.find_by(id: collection.id)
      expect(reloaded).to have_attributes title: contain_exactly("Updated Collection")
    end
  end

  context "nested collection" do
    let(:user) { User.create(email: "comet-admin@library.ucsd.edu") }

    let(:collection) do
      FactoryBot.valkyrie_create(:collection,
        :with_index,
        :with_permission_template,
        title: ["Test Collection"],
        edit_users: [user],
        member_of_collection_ids: [nested_collection.id, another_nested_collection.id],
        read_users: [user],
        user: user)
    end

    let(:nested_collection) do
      FactoryBot.valkyrie_create(:collection,
        :with_index,
        :with_permission_template,
        title: ["Nested Collection"],
        edit_users: [user],
        read_users: [user],
        user: user)
    end

    let(:another_nested_collection) do
      FactoryBot.valkyrie_create(:collection,
        :with_index,
        :with_permission_template,
        title: ["Another Nested Collection"],
        edit_users: [user],
        read_users: [user],
        user: user)
    end

    it "shows the nested collections" do
      visit "/dashboard/collections/#{collection.id}"

      within("section#parent-collections-wrapper") do
        expect(page).to have_content("Nested Collection")
        expect(page).to have_content("Another Nested Collection")
      end
    end
  end

  context "collection object members" do
    before do
      obj_a = ::GenericObject.new(
        title: ["Test Member Object A"],
        member_of_collection_ids: [collection.id]
      )
      Hyrax.index_adapter.save(
        resource: Hyrax.persister.save(resource: obj_a)
      )

      obj_b = ::GenericObject.new(
        title: ["Test Member Object B"],
        member_of_collection_ids: [collection.id]
      )
      Hyrax.index_adapter.save(
        resource: Hyrax.persister.save(resource: obj_b)
      )
    end

    it "display object members to authorized user" do
      visit "/dashboard/collections/#{collection.id}"

      expect(page).to have_content("Test Member Object A")
      expect(page).to have_content("Test Member Object B")
    end
  end

  context "collections created by other users" do
    let(:other_user) { User.find_or_create_by(email: "comet-user@library.ucsb.edu") }

    before do
      FactoryBot.valkyrie_create(:collection,
        :with_index,
        :with_permission_template,
        title: ["Other User's Collection"],
        edit_users: [other_user, user],
        member_of_collection_ids: [],
        user: other_user)
    end

    it "shows other user's collections" do
      visit "/dashboard/collections"

      expect(page).to have_link("Other User's Collection")
    end
  end
end
