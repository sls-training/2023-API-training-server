# frozen_string_literal: true

FactoryBot.define do
  factory :access_token do
    token { SecureRandom.base64 }
    scope { 'READ WRITE' }
    expires_in { 1.hour }
    association :user
  end
end
