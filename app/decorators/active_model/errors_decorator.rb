# frozen_string_literal: true

module ActiveModel
  class ErrorsDecorator
    def initialize(errors)
      @errors = errors
    end

    def to_a
      @errors.messages.map do |name, reasons|
        reasons.map { |reason| { name:, reason: } }
      end.flatten
    end
  end
end
