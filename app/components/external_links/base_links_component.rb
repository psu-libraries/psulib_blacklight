# frozen_string_literal: true

module ExternalLinks
  class BaseLinksComponent < ViewComponent::Base
    def initialize(links:, heading: nil, show_links: true)
      @links = links
      @heading = heading
      @show_links = show_links
      @data_target = data_target
    end

    def render?
      links.present? && show_links?
    end

    def render_view_more?
      view_more_links.present? && show_links?
    end

    def preview_links
      return links if links.length <= 3

      links.slice(0, 2)
    end

    def view_more_links
      return if links.length <= 3

      links.slice(2, links.length - 2)
    end

    private

      attr_reader :links, :heading

      def show_links?
        !!@show_links
      end

      def data_target
        "collapseLinks#{@heading.parameterize(separator: '', preserve_case: true)}" if @heading.present?
      end
  end
end
