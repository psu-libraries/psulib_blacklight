# frozen_string_literal: true

class TermsQuery
  def self.call(field:, limit:, query:, include_lower: 'true')
    new(field, limit, query, include_lower).terms
  end

  attr_reader :field, :limit, :query

  def initialize(field, limit, query, include_lower)
    @field = field
    @limit = limit
    @query = query
    @include_lower = include_lower
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
             'terms.lower.incl' => include_lower?,
             'terms.fl' => field,
             'terms.lower' => query,
             'terms.limit' => limit,
             'terms.sort' => 'index'
           })
      .dig('terms', field) || []
  end

  private

    def include_lower?
      @include_lower != 'false'
    end
end
