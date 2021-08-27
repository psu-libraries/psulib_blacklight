# frozen_string_literal: true

module Browse
  class SubjectNavigation < Navigator
    delegate :page, :length, to: :list

    def previous_path
      browse_subjects_path(
        merge_params(page: page - 1, length: length)
      )
    end

    def next_path
      browse_subjects_path(
        merge_params(page: page + 1, length: length)
      )
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

    private

      def merge_params(opts)
        params.slice(:prefix).merge(opts)
      end
  end
end
