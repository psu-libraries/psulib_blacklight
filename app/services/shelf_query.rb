# frozen_string_literal: true

class ShelfQuery
  DEWEY_SHELF_PREFIX = 'AAA'

  def self.call(field:, limit:, query:, include_lower: false, include_more: false)
    new(field, limit, query, include_lower, include_more).docs
  end

  attr_reader :field, :limit, :query, :include_lower

  def initialize(field, limit, query, include_lower, include_more)
    @field = field
    @limit = limit
    @query = query
    @include_lower = include_lower
    @include_more = include_more
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
             'qt' => 'shelf',
             'sort' => sort,
             'rows' => limit
           })
      .dig('response', 'docs') || []
  end

  private

    def filter_query
      if include_lower
        "#{field}:[#{range_limit} TO #{escape_ws(query)}]"
      else
        "#{field}:[#{escape_ws(query)} TO #{range_limit}]"
      end
    end

    def sort
      "stringdiff(#{field}, #{escape_ws(query)}, #{include_lower}) asc"
    end

    def range_limit
      result = if include_lower
                 range_limit_lower
               else
                 range_limit_higher
               end

      return '*' if result == query[0]

      result.insert(0, DEWEY_SHELF_PREFIX) if dewey?

      escape_ws(result)
    end

    def range_limit_lower
      query[char_pos].tr(low_limit_tr, up_limit_tr)
    end

    def range_limit_higher
      query[char_pos].tr(up_limit_tr, low_limit_tr)
    end

    def dewey?
      field.include?('dewey') && query.starts_with?(DEWEY_SHELF_PREFIX)
    end

    def char_pos
      dewey? ? 3 : 0
    end

    def low_limit_tr
      if @include_more
        'e-zE-Z5-9'
      else
        'c-zC-Z3-9'
      end
    end

    def up_limit_tr
      if @include_more
        'a-xA-X0-5'
      else
        'a-xA-X0-7'
      end
    end

    def escape_ws(query)
      /\s/.match?(query) ? "\"#{query}\"" : query
    end
end
