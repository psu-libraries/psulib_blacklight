# frozen_string_literal: true

module Browse
  class AuthorNavigation < Navigator
    delegate :page, :length, to: :list

    def previous_path
      browse_authors_path(
        merge_params(page: page - 1, length: length)
      )
    end

    def next_path
      browse_authors_path(
        merge_params(page: page + 1, length: length)
      )
    end

    private

      def merge_params(opts)
        params.slice(:prefix).merge(opts)
      end
  end
end
