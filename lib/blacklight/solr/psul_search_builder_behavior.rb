# frozen_string_literal: true
module Blacklight::Solr
  module PsulSearchBuilderBehavior
    private

    ##
    # Convert a facet/value pair into a solr fq parameter
    def facet_value_to_fq_string(facet_field, value)
      facet_config = blacklight_config.facet_fields[facet_field]

      solr_field = facet_config.field if facet_config && !facet_config.query
      solr_field ||= facet_field

      local_params = []
      local_params << "tag=#{facet_config.tag}" if facet_config && facet_config.tag

      prefix = "{!#{local_params.join(' ')}}" unless local_params.empty?

      if facet_config && facet_config.query
        if facet_config.query[value]
          facet_config.query[value][:fq]
        else
          # exclude all documents if the custom facet key specified was not found
          '-*:*'
        end
      elsif value.is_a?(Range)
        "#{prefix}#{solr_field}:[#{value.first} TO #{value.last}]"
      else
        "#{solr_field}:\"#{convert_to_term_value(value)}\""
      end
    end
  end
end
