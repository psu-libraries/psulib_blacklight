# frozen_string_literal: true

module Browse
  extend ActiveSupport::Concern

  def redirect_browse
    return if params[:q].blank?

    case params[:search_field]
    when 'browse_cn'
      redirect_to call_number_browse_path(nearby: params[:q])
    when 'browse_authors'
      redirect_to author_browse_path(prefix: params[:q])
    when 'browse_subjects'
      redirect_to subject_browse_path(prefix: params[:q])
    when 'browse_titles'
      redirect_to title_browse_path(prefix: params[:q])
    end
  end
end
