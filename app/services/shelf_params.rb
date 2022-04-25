# frozen_string_literal: true

class ShelfParams
  DEWEY_SHELF_PREFIX = 'AAA'

  attr_reader :field, :query, :include_lower

  def initialize(field:, query:, include_lower: false, include_more: false)
    @field = field
    @query = query
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
