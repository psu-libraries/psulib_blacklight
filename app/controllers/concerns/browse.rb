# frozen_string_literal: true

module Browse
  extend ActiveSupport::Concern

  def redirect_browse
    if params[:q] && params[:search_field] == 'browse_cn'
      redirect_to "/browse/?nearby=#{CGI.escape params[:q]}"
    end
  end
end
