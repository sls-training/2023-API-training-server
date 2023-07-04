# frozen_string_literal: true

class ItemResource
  include Alba::Resource

  attributes :id, :name, :description

  attribute :size do |item|
    item.file.byte_size
  end

  attribute :created_at do |item|
    item.created_at.iso8601
  end

  attribute :updated_at do |item|
    item.updated_at.iso8601
  end
end
