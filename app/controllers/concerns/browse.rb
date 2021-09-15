# frozen_string_literal: true

module Browse
  extend ActiveSupport::Concern

  def redirect_browse
    return if params[:q].blank?

    case params[:search_field]
    when 'browse_cn'
      redirect_to browse_path(nearby: params[:q])
    when 'browse_authors'
      redirect_to browse_authors_path(prefix: params[:q])
    when 'browse_subjects'
      redirect_to browse_subjects_path(prefix: params[:q])
    when 'browse_titles'
      redirect_to browse_titles_path(prefix: params[:q])
    end
  end
end
