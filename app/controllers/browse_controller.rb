# frozen_string_literal: true

class BrowseController < ApplicationController
  def index
    @shelf_list = ShelfListPresenter.new(presenter_params)
  end

  private

    def presenter_params
      params.permit(:starting, :ending, :length, :nearby)
    end
end
