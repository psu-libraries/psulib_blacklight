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

  def bulk_ris
    bulk_string = ''
    document_ids = action_documents.first['response']['docs'].map { |doc| doc['id'] }
    document_ids.each do |id|
      solr_document = search_service.fetch(id)
      bulk_string += DocumentRis.new(solr_document).ris_to_string
    end

    send_data bulk_string, filename: 'document.ris', type: :ris
  end

  configure_blacklight do |config|
    config.index.collection_actions.delete(:sort_widget)
    config.add_show_tools_partial(:bulk_ris, callback: :bulk_ris_action, html_class: 'dropdown-item')
  end
end
