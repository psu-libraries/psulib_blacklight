# frozen_string_literal: true

class BookmarksController < CatalogController
  include Blacklight::Bookmarks

  before_action :authenticate_user!

  configure_blacklight do |config|
    config.index.collection_actions.delete(:sort_widget)
  end
end
