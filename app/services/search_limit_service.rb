# frozen_string_literal: true

class SearchLimitService
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def search_volume_exceeded?
    limit = ENV.fetch('QUERY_CHAR_LIMIT', 45).to_i
    total_search_volume > limit
  end

  private

    def total_search_volume
      # facets weighted as 15 characters each
      char_count = num_query_fields * 15

      advanced_search_clause_values.each do |value|
        char_count += value['query'].length if value['query'].present?
      end

      char_count += params['q'].length if params['q'].present?
      char_count
    end

    def num_query_fields
      advanced_search_clauses = advanced_search_clause_values.count { |value| value['query'].present? }
      advanced_search_facets = params.fetch('f_inclusive', {}).values.flatten.count
      index_facets = params.fetch('f', {}).values.flatten.count

      advanced_search_clauses + advanced_search_facets + index_facets
    end

    def advanced_search_clause_values
      params.fetch('clause', {}).values
    end
end
