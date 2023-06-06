# frozen_string_literal: true

"Label".constantize # must be autoloaded for string → label coersion to work

FactoryBot.define do
  factory :concept do
    pref_label { ["A Concept"] }
    id { "just_fake_id" }
  end
end
