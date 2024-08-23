# frozen_string_literal: true

class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  include ClauseCountLimiter
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr,
                                   :add_all_online_to_query, :limit_clause_count]

  def add_all_online_to_query(solr_parameters)
    if campus_facet_all_online_query?(solr_parameters)
      solr_parameters[:fq] ||= []

      solr_parameters[:fq].first.prepend('access_facet:Online OR ')
      solr_parameters[:fq][0] = solr_parameters[:fq].first.gsub('}', " v='") << "'}"
    end
  end

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end

  private

    def campus_facet_all_online_query?(solr_parameters)
      blacklight_params['add_all_online'] == 'true' &&
        solr_parameters[:fq]&.count == 1 &&
        solr_parameters[:fq]&.first&.include?('tag=campus_facet_single')
    end
end
