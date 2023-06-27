# frozen_string_literal: true

module ProblemDetails
  class ItemResource
    include Alba::Resource

    many :errors, resource: ProblemDetails::ActiveModel::ErrorsResource

    def to_hash
      to_h
    end
  end
end
