# frozen_string_literal: true

class ShelfQuery
  def self.call(field:, limit:, query:, include_lower: false)
    new(field, limit, query, include_lower).docs
  end

  attr_reader :field, :limit, :query, :include_lower

  def initialize(field, limit, query, include_lower)
    @field = field
    @limit = limit
    @query = query
    @include_lower = include_lower
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
             'fq' => filter_query,
             'sort' => sort,
             'rows' => limit
           })
      .dig('response', 'docs') || []
  end

  private

    def filter_query
      if include_lower
        "#{field}:[* TO \"#{query}\"]"
      else
        "#{field}:[\"#{query}\" TO *]"
      end
    end

    def sort
      "stringdiff(#{field}, \"#{query}\", #{include_lower}) asc"
    end
end
