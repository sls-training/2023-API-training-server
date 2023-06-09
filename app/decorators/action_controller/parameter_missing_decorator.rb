# frozen_string_literal: true

module ActionController
  class ParameterMissingDecorator
    def initialize(error)
      @error = error
    end

    def to_a
      [{ name: @error.param, reason: 'is missing or the value is empty' }]
    end
  end
end
