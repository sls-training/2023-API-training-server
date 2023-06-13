# frozen_string_literal: true

module ProblemDetails
  class UserResource
    include Alba::Resource

    many :errors, resource: ProblemDetails::ActiveModel::ErrorsResource
  end
end
