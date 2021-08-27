# frozen_string_literal: true

module Browse
  class PrefixSelector < ViewComponent::Base
    def prefix
      params[:prefix]
    end

    def clear_prefix_path
      browse_subjects_path(merge_params)
    end

    def prefix_path(letter)
      browse_subjects_path(merge_params(prefix: letter))
    end

    private

      def merge_params(opts = {})
        params.slice(:length).merge(opts)
      end
  end
end
