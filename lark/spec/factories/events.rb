# frozen_string_literal: true

FactoryBot.define do
  factory :event, aliases: [:create_event] do
    type { :create }
  end
end
