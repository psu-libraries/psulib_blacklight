# frozen_string_literal: true

module Browse
  class NearbyButton < ViewComponent::Base
    attr_reader :call_numbers

    def initialize(call_numbers:)
      @call_numbers = call_numbers
    end

    def render?
      call_numbers.present?
    end
  end
end
