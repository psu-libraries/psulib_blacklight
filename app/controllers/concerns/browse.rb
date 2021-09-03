# frozen_string_literal: true

module Browse
  extend ActiveSupport::Concern

  def redirect_browse
    return if params[:q].blank?

    case params[:search_field]
    when 'browse_cn'
      redirect_to browse_path(nearby: search_params)
    when 'browse_authors'
      redirect_to browse_authors_path(prefix: search_params)
    when 'browse_subjects'
      redirect_to browse_subjects_path(prefix: search_params)
    end
  end

  private

    def search_params
      CGI.escape(params[:q])
    end
end
