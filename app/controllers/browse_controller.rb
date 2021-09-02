# frozen_string_literal: true

class BrowseController < ApplicationController
  before_action :normalize_parameters

  def index
    @shelf_list = ShelfListPresenter.new(shelf_list_params)
  end

  def subjects
    @subject_list = BrowseList.new(subject_list_params)
  end

  def authors
    @author_list = BrowseList.new(author_list_params)
  end

  private

<<<<<<< HEAD
    def normalize_parameters
      params[:prefix].try(:capitalize!)
    end

    def author_params
      params.permit(:length, :page, :prefix)
=======
    def author_list_params
      params
        .permit(:length, :page, :prefix)
        .to_hash
        .merge(field: 'all_authors_facet')
        .symbolize_keys
>>>>>>> 65ec8f0 (Refactor components (#860))
    end

    def shelf_list_params
      params.permit(:starting, :ending, :length, :nearby)
    end

    def subject_list_params
      params
        .permit(:length, :page, :prefix)
        .to_hash
        .merge(field: 'subject_browse_facet')
        .symbolize_keys
    end
end
