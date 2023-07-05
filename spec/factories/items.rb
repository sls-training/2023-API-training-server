# frozen_string_literal: true

FactoryBot.define do
  factory :item do
    name { Faker::File.file_name }
  end
end
