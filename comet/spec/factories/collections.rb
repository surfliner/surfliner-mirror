FactoryBot.define do
  factory :collection, class: "Hyrax::PcdmCollection", aliases: [:hyrax_collection, :pcdm_collection] do
    sequence(:title) { |n| ["The Tove Jansson Collection #{n}"] }

    collection_type_gid { Hyrax::CollectionType.find_or_create_default_collection_type.to_global_id.to_s }

    trait :with_permission_template do
      transient do
        user { create(:user) }
        edit_groups { [] }
        edit_users { [] }
        read_groups { [] }
        read_users { [] }
        access_grants { [] }
      end

      after(:create) do |collection, evaluator|
        Hyrax::Collections::PermissionsCreateService.create_default(collection: collection,
          creating_user: evaluator.user,
          grants: evaluator.access_grants)
        collection.permission_manager.edit_groups = collection.permission_manager.edit_groups.to_a +
          evaluator.edit_groups
        collection.permission_manager.edit_users = collection.permission_manager.edit_users.to_a +
          evaluator.edit_users
        collection.permission_manager.read_groups = collection.permission_manager.read_groups.to_a +
          evaluator.read_groups
        collection.permission_manager.read_users = collection.permission_manager.read_users.to_a +
          evaluator.read_users
        collection.permission_manager.acl.save
      end
    end

    trait :with_index do
      after(:create) do |collection|
        Hyrax.index_adapter.save(resource: collection)
      end
    end
  end
end
