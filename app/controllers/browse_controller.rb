# frozen_string_literal: true

class BrowseController < ApplicationController
  def index
    @documents = ShelfList.call(call_number: params[:q])
  end
end
