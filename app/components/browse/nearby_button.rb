# frozen_string_literal: true

module Browse
  class NearbyButton < ViewComponent::Base
    attr_reader :call_numbers

    def initialize(call_numbers:)
      @call_numbers = call_numbers
    end

    def render?
      # TODO: browse nearby button disabled on production
      return false if Settings.matomo_id.to_i == 7

      call_numbers.present?
    end
  end
end
