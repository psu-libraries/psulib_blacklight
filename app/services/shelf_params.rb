# frozen_string_literal: true

class ShelfParams
  DEWEY_SHELF_PREFIX = 'AAA'

  attr_reader :field, :query, :include_lower

  def initialize(field:, query:, include_lower: false, include_more: false)
    @field = field
    @query = query.upcase
    @include_lower = include_lower
    @include_more = include_more
  end

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

  private

    def range_limit
      result = if include_lower
                 range_limit_lower
               else
                 range_limit_higher
               end

      # If range limit translates to the same value as the query's initial char
      # this means we are searching the edges of the limits for example LC query
      # with letter "Z", so we can use "*" to return the rest the documents.
      return '*' if result == query[first_char_pos]

      result.insert(0, DEWEY_SHELF_PREFIX) if dewey?

      result
    end

    def range_limit_lower
      query[first_char_pos].tr(low_limit_tr, up_limit_tr)
    end

    def range_limit_higher
      query[first_char_pos].tr(up_limit_tr, low_limit_tr)
    end

    def dewey?
      field.include?('dewey') && query.starts_with?(DEWEY_SHELF_PREFIX)
    end

    def first_char_pos
      dewey? ? 3 : 0
    end

    def low_limit_tr
      if @include_more
        dewey? ? '5-9' : 'E-Z'
      else
        dewey? ? '3-9' : 'C-Z'
      end
    end

    def up_limit_tr
      if @include_more
        dewey? ? '0-5' : 'A-V'
      else
        dewey? ? '0-7' : 'A-X'
      end
    end

    def escape_ws(query)
      /\s/.match?(query) ? "\"#{query}\"" : query
    end
end
