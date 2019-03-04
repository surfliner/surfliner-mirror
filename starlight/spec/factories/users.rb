# This is necessary because the upstream :user factory in Spotlight current assumes there is a password property
# (see https://github.com/projectblacklight/spotlight/blob/v2.3.2/spec/factories/users.rb#L7 )
FactoryBot.define do
  factory :omniauth_user, class: User do
    transient do
      exhibit { FactoryBot.create(:exhibit) }
    end
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:uid) { |n| "user#{n}" }

    factory :omniauth_site_admin do
      after(:create) do |user, _evaluator|
        user.roles.create role: 'admin', resource: Spotlight::Site.instance
      end
    end

    factory :omniauth_exhibit_admin do
      after(:create) do |user, evaluator|
        user.roles.create role: 'admin', resource: evaluator.exhibit
      end
    end

    factory :omniauth_exhibit_curator do
      after(:create) do |user, evaluator|
        user.roles.create role: 'curator', resource: evaluator.exhibit
      end
    end

    factory :omniauth_exhibit_visitor do
    end
  end
end
