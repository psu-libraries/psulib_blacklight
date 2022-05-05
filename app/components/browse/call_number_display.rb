# frozen_string_literal: true

module Browse
  class CallNumberDisplay < ViewComponent::Base
    attr_reader :call_number, :list, :id

    def initialize(call_number:, list:, id:)
      @call_number = call_number
      @list = list
      @id = id
    end

    def render?
      call_number.present? && id.present?
    end
  end
end
