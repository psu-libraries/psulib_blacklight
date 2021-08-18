# frozen_string_literal: true

module Browse
  class Navigator < ViewComponent::Base
    attr_reader :list

    def initialize(list:)
      @list = list
    end
  end
end
