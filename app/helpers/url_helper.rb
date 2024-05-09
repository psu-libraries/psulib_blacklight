# frozen_string_literal: true

module UrlHelper
  include Blacklight::UrlHelperBehavior
  ##
  # Attributes for a link that gives a URL we can use to track clicks for the current search session
  # @param [SolrDocument] document
  # @param [Integer] counter
  # @example
  #   session_tracking_params(SolrDocument.new(id: 123), 7)
  #   => { data: { :'context-href' => '/catalog/123/track?counter=7&search_id=999' } }

  def session_tracking_params document, counter, per_page: search_session['per_page'], search_id: current_search_session&.id
    path_params = { per_page: params.fetch(:per_page, per_page), counter: counter, search_id: search_id }
    if blacklight_config.track_search_session.storage == 'server'
      path_params[:document_id] = document&.id
      path_params[:search_id] = search_id
    end
    path = session_tracking_path(document, path_params)
    return {} if path.nil?

    context_method = blacklight_config.track_search_session.storage == 'client' ? 'get' : 'post'
    { data: { context_href: path, context_method: context_method, turbo_prefetch: false } }
  end
end
