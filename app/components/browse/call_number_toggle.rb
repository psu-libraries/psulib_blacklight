# frozen_string_literal: true

module Browse
  class CallNumberToggle < ViewComponent::Base
    attr_reader :list, :id

    def initialize(list:, id:)
      @list = list
      @id = id
    end

    def render?
      list.present? && id.present?
    end

    def target
      "moreCallNumbers#{id}"
    end
  end
end
