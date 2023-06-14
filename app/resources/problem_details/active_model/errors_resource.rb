# frozen_string_literal: true

module ProblemDetails
  module ActiveModel
    class ErrorsResource
      include Alba::Resource

      attribute :name, &:attribute
      attribute :reason, &:message
    end
  end
end
