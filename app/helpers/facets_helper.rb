# frozen_string_literal: true

module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  def initial_collapse(field_name, display_facet)
    if display_facet.instance_of?(Blacklight::Solr::Response::Facets::FacetItem)
      pivot_facet_child_in_params?(field_name, display_facet) ? 'collapse show' : 'collapse'
    else
      'facet-values'
    end
  end

  def facet_value_id(display_facet)
    if display_facet.respond_to?(:value)
      "id=#{display_facet.field.parameterize}-#{display_facet.value.parameterize}"
    else
      ''
    end
  end

  def pivot_facet_child_in_params?(field_name, item, pivot_in_params = false)
    pivot_in_params = true if pivot_facet_in_params?(field_name, item)
    if item.items.present?
      item.items.each do |pivot_item|
        pivot_in_params = true if pivot_facet_child_in_params?(pivot_item.field, pivot_item)
      end
    end
    pivot_in_params
  end

  def pivot_facet_in_params?(field_name, item)
    field_name = item.field if item.respond_to?(:field)

    value = facet_value_for_facet_item(item)
    params[:f] && params[:f][field_name] && params[:f][field_name].include?(value)
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

  def facet_item_component_class(facet_config)
    default_component = facet_config.pivot ? Blacklight::FacetItemPivotComponent : PsulFacetItemComponent
    facet_config.fetch(:item_component, default_component)
  end

  def campus_facet_all_online_links
    if params[:f]&.keys == ['campus_facet']
      if params[:add_all_online].present?
        link_to(
          'Remove online results',
          "?#{params.except(:controller, :action, :add_all_online).to_query}",
          class: 'btn btn-outline-secondary btn-sm mt-2'
        )
      else
        link_to(
          'Include all online results',
          "?#{params.except(:controller, :action, :add_all_online).to_query}&add_all_online=true",
          class: 'btn btn-outline-primary btn-sm mt-2'
        )
      end
    end
  end
end
