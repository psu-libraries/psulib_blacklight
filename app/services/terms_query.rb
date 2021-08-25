# frozen_string_literal: true

class TermsQuery
  def self.call(field:, limit:, query:)
    new(field, limit, query).terms
  end

  attr_reader :field, :limit, :query

  def initialize(field, limit, query)
    @field = field
    @limit = limit
    @query = query
  end

  # @return [Array<String>]
  def terms
    return [] if limit.zero?

    solr_query.try(:keys) ||
      solr_query
        .each_slice(2)
        .map(&:first)
  end

  def solr_query
    @solr_query ||= Blacklight
      .default_index
      .connection
      .get('terms',
           params: {
             'terms' => true,
             'terms.lower.incl' => true,
             'terms.fl' => field,
             'terms.lower' => query,
             'terms.limit' => limit,
             'terms.sort' => 'index'
           })
      .dig('terms', field) || []
  end
end
