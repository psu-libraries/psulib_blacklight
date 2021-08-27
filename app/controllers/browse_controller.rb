# frozen_string_literal: true

class BrowseController < ApplicationController
  def index
    @shelf_list = ShelfListPresenter.new(shelf_list_params)
  end

  def subjects
    @subject_list = SubjectList.new(subject_params)
  end

  private

    def shelf_list_params
      params.permit(:starting, :ending, :length, :nearby)
    end

    def subject_params
      params.permit(:length, :page, :prefix)
    end
end
