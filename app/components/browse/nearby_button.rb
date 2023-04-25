# frozen_string_literal: true

module Browse
  class NearbyButton < ViewComponent::Base
    attr_reader :call_numbers, :classification

    def initialize(call_numbers:, classification:)
      @call_numbers = call_numbers
      @classification = classification
    end

    def render?
      call_numbers.present?
    end
  end
end
