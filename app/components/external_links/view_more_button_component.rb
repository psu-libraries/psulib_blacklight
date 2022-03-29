# frozen_string_literal: true

module ExternalLinks
  class ViewMoreButtonComponent < ViewComponent::Base
    attr_reader :data_target

    def initialize(links:, target:)
      @links = links
      @data_target = target
    end

    def render?
      @links.present?
    end
  end
end
