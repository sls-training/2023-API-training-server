# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password min_length: 16 }

    trait :with_access_tokens do
      transient do
        token_count { 1 }
      end

      after(:create) do |user, context|
        context.token_count.times { user.access_tokens << create(:access_token) }
      end
    end
  end
end
