# frozen_string_literal: true

class BookmarksController < CatalogController
  include Blacklight::Bookmarks

  configure_blacklight do |config|
    _config.index.collection_actions.delete(:sort_widget)
  end
end
