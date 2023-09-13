FactoryBot.define do
  factory :project, class: "Hyrax::AdministrativeSet" do
    sequence(:title) { |n| ["Test Project #{n}"] }

    transient do
      user { create(:user) }
    end

    after(:build) do |project, evaluator|
      project.creator = [evaluator.user.user_key]
    end

    trait :with_permission_template do
      transient do
        access_grants do
          [{agent_type: Hyrax::PermissionTemplateAccess::USER,
            agent_id: user.user_key,
            access: Hyrax::PermissionTemplateAccess::MANAGE}]
        end
        additional_access_grants { [] }
      end

      after(:create) do |project, evaluator|
        template = Hyrax::PermissionTemplate.find_or_create_by(source_id: project.id.to_s)
        grants = (access_grants + additional_access_grants).uniq

        grants.each do |grant|
          Hyrax::PermissionTemplateAccess.find_or_create_by(permission_template_id: template.id,
            agent_type: grant[:agent_type],
            agent_id: grant[:agent_id],
            access: grant[:access])
        end
      end
    end

    trait :with_index do
      after(:create) do |project, _e|
        Hyrax.index_adapter.save(resource: project)
      end
    end
  end
end
