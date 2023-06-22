# frozen_string_literal: true

FactoryBot.define do
  factory :access_token do
    association :user
  end
end
