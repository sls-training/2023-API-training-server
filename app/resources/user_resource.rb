# frozen_string_literal: true

class UserResource
  include Alba::Resource

  attributes :id, :name, :email

  attribute :created_at do |user|
    user.created_at.iso8601
  end

  attribute :updated_at do |user|
    user.updated_at.iso8601
  end
end
