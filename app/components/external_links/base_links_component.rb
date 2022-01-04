# frozen_string_literal: true

module ExternalLinks
  class BaseLinksComponent < ViewComponent::Base
    def initialize(links:, heading: nil, show_links: true)
      @links = links
      @heading = heading
      @show_links = show_links
    end

    def render?
      links.present? && show_links?
    end

    private

      attr_reader :links, :heading

      def show_links?
        !!@show_links
      end
  end
end
