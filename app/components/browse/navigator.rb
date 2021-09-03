# frozen_string_literal: true

module Browse
  class Navigator < ViewComponent::Base
    attr_reader :list

    def initialize(list:)
      @list = list
    end

    def next_title
      'View next page of results'
    end

    def previous_title
      'View previous page of results'
    end

    def previous?
      page > 1
    end

    def next?
      !list.last_page?
    end
  end
end
