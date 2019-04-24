# frozen_string_literal: true

module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  def initial_collapse(field, display_facet)
    if display_facet.class == Blacklight::Solr::Response::Facets::FacetItem
      pivot_facet_child_in_params?(field, display_facet) ? 'collapse show' : 'collapse'
    else
      'facet-values'
    end
  end

  def facet_value_id(display_facet)
    if display_facet.respond_to?('value')
      "id=#{display_facet.field.parameterize}-#{display_facet.value.parameterize}"
    else
      ''
    end
  end

  def pivot_facet_child_in_params?(field, item, pivot_in_params = false)
    pivot_in_params = true if pivot_facet_in_params?(field, item)
    if item.items.present?
      item.items.each do |pivot_item|
        pivot_in_params = true if pivot_facet_child_in_params?(pivot_item.field, pivot_item)
      end
    end
    pivot_in_params
  end

  def pivot_facet_in_params?(field, item)
    field = item.field if item && item.respond_to?(:field)

    value = facet_value_for_facet_item(item)
    params[:f] && params[:f][field] && params[:f][field].include?(value)
  end

  ##
  # Are any facet restrictions for a field in the query parameters?
  #
  # @param [String] facet field
  # @return [Boolean]
  def facet_field_in_params?(field)
    pivot = facet_configuration_for_field(field).pivot
    if pivot
      pivot_facet_field_in_params?(pivot)
    else
      params[:f] && params[:f][field]
    end
  end

  def pivot_facet_field_in_params?(pivot)
    in_params = false
    pivot.each { |field| in_params = true if params[:f] && params[:f][field] }
    in_params
  end
end
