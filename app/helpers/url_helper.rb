module UrlHelper
  include Blacklight::UrlHelperBehavior
  ##
  # Attributes for a link that gives a URL we can use to track clicks for the current search session
  # @param [SolrDocument] document
  # @param [Integer] counter
  # @example
  #   session_tracking_params(SolrDocument.new(id: 123), 7)
  #   => { data: { :'context-href' => '/catalog/123/track?counter=7&search_id=999' } }
  def session_tracking_params document, counter
    path = session_tracking_path(document, per_page: params.fetch(:per_page, search_session['per_page']), counter: counter, search_id: current_search_session.try(:id), document_id: document&.id)

    if path.nil?
      return {}
    end

    { data: { 'context-href': path } }
  end
end