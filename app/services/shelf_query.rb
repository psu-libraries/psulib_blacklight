# frozen_string_literal: true

class ShelfQuery
  def self.call(limit:, params:)
    new(limit, params).docs
  end

  attr_reader :limit, :params

  def initialize(limit, params)
    @limit = limit
    @params = params
  end

  # @return [Array<String>]
  def docs
    return [] if limit.zero?

    solr_query
  end

  def solr_query
    @solr_query ||= Blacklight
      .default_index
      .connection
      .get('select',
           params: {
             'q' => '*:*',
             'fq' => params.filter_query,
             'qt' => 'shelf',
             'sort' => params.sort,
             'rows' => limit
           })
      .dig('response', 'docs') || []
  end
end
