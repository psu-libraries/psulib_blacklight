# frozen_string_literal: true

module Browse
  class PrefixSelector < ViewComponent::Base
    def prefix
      params[:prefix]
    end

    def clear_prefix_path
      raise ArgumentError, "no path defined for '#{action}'" unless respond_to?("#{action}_path", true)

      send("#{action}_path", merge_params)
    end

    def prefix_path(letter)
      raise ArgumentError, "no path defined for '#{action}'" unless respond_to?("#{action}_path", true)

      send("#{action}_path", merge_params(prefix: letter))
    end

    def form_url
      raise ArgumentError, "no form URL defined for '#{action}'" unless respond_to?("#{action}_form_url", true)

      send("#{action}_form_url")
    end

    private

      def action
        @action ||= params.fetch(:action) { raise KeyError, 'params must include :action' }
      end

      def authors_form_url
        browse_authors_url
      end

      def authors_path(params)
        browse_authors_path(params)
      end

      def subjects_form_url
        browse_subjects_url
      end

      def subjects_path(params)
        browse_subjects_path(params)
      end

      def merge_params(opts = {})
        params.slice(:length).merge(opts)
      end
  end
end
