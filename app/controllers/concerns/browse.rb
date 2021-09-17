# frozen_string_literal: true

module Browse
  extend ActiveSupport::Concern

  def redirect_browse
    case params[:search_field]
    when 'browse_lc'
      redirect_to call_number_browse_path(nearby: params[:q], classification: 'lc')
    when 'browse_dewey'
      redirect_to call_number_browse_path(nearby: params[:q], classification: 'dewey')
    when 'browse_authors'
      redirect_to author_browse_path(prefix: params[:q])
    when 'browse_subjects'
      redirect_to subject_browse_path(prefix: params[:q])
    when 'browse_titles'
      redirect_to title_browse_path(prefix: params[:q])
    end
  end
end
