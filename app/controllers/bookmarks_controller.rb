# frozen_string_literal: true

class BookmarksController < CatalogController
  include Blacklight::Bookmarks

  before_action :authenticate_user!

  # when logging in, the HTTP_REFERER header gets reset, thus sending the user
  # back to '/' here we pass redirect_location around, and set it as the HTTP_REFERER
  # when initalizing a bookmark after logging in for the first time
  # this allows the create method to return the guest to the appropriate place
  def initialize_bookmark
    if params['redirect_location']
      request.headers['HTTP_REFERER'] = params['redirect_location']
    end
    create
  end

  configure_blacklight do |config|
    config.index.collection_actions.delete(:sort_widget)
  end
end
