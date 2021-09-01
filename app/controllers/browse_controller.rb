# frozen_string_literal: true

class BrowseController < ApplicationController
  before_action :normalize_parameters

  def index
    @shelf_list = ShelfListPresenter.new(shelf_list_params)
  end

  def subjects
    @subject_list = SubjectList.new(subject_params)
  end

  def authors
    @author_list = AuthorList.new(author_params)
  end

  private

    def normalize_parameters
      params[:prefix].try(:capitalize!)
    end

    def author_params
      params.permit(:length, :page, :prefix)
    end

    def shelf_list_params
      params.permit(:starting, :ending, :length, :nearby)
    end

    def subject_params
      params.permit(:length, :page, :prefix)
    end
end
