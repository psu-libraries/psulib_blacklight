# frozen_string_literal: true

module Browse
  class PageSizeSelector < ViewComponent::Base
    def link_path(length)
      raise ArgumentError, "no path defined for '#{action}'" unless respond_to?("#{action}_path", true)

      send("#{action}_path", length)
    end

    private

      def action
        @action ||= params.fetch(:action) { raise KeyError, 'params must include :action' }
      end

      def index_path(length)
        browse_path(
          merge_params(
            length: length,
            starting: params[:starting],
            ending: params[:ending],
            nearby: params[:nearby]
          )
        )
      end

      def authors_path(length)
        browse_authors_path(
          merge_params(
            page: params[:page],
            length: length
          )
        )
      end

      def subjects_path(length)
        browse_subjects_path(
          merge_params(
            page: params[:page],
            length: length
          )
        )
      end

      def merge_params(opts)
        params.slice(:prefix).merge(opts)
      end
  end
end
