# frozen_string_literal: true

module Browse
  class PageSizeSelector < ViewComponent::Base
    include Paths

    def link_path(length)
      browse_path(merge_params(length: length))
    end

    private

      def merge_params(opts)
        params
          .slice(:prefix, :page, :starting, :ending, :nearby)
          .merge(opts)
      end
  end
end
