# frozen_string_literal: true

module Browse
  class FacetNavigation < Navigator
    include Paths

    delegate :page, :length, to: :list

    def previous_path
      browse_path(merge_params(page: page - 1, length: length))
    end

    def next_path
      browse_path(merge_params(page: page + 1, length: length))
    end

    private

      def merge_params(opts)
        params.slice(:prefix).merge(opts)
      end
  end
end
