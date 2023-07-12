FactoryBot.define do
  factory :generic_object, class: "GenericObject", aliases: [:hyrax_object, :pcdm_object] do
    sequence(:title) { |n| "Complete Moomin Comics; vol #{n}" }

    trait :with_index do
      after(:create) do |object|
        Hyrax.index_adapter.save(resource: object)
      end
    end
  end

  factory :geospatal_object, class: "GeospatialObject", aliases: [:geo_object] do
    sequence(:title) { |n| "Maps of Africa; vol #{n}" }

    trait :with_index do
      after(:create) do |object|
        Hyrax.index_adapter.save(resource: object)
      end
    end
  end
end
