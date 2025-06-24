# frozen_string_literal: true

class PsulFacetItemComponent < Blacklight::FacetItemComponent
  def initialize(facet_item:, wrapping_element: 'li', suppress_link: false)
    super(facet_item: facet_item, wrapping_element: wrapping_element, suppress_link: suppress_link)
  end

  ##
  # Standard display of a facet value in a list. Used in both _facets sidebar
  # partial and catalog/facet expanded list. Will output facet value name as
  # a link to add that to your restrictions, with count in parens.
  #
  # @return [String]
  # @private
  def render_facet_value
    tag.span(class: 'facet-label') do
      link_to_unless(@suppress_link, @label, @href, class: 'facet-select', title: facet_tooltip(@label))
    end + render_facet_count
  end

  ##
  # Standard display of a SELECTED facet value (e.g. without a link and with a remove button)
  # @see #render_facet_value
  #
  # @private
  def render_selected_facet_value
    tag.span(class: 'facet-label') do
      tag.span(@label, class: 'selected', title: facet_tooltip(@label)) +
        # remove link
        link_to(@href, class: 'remove') do
          tag.span('✖', class: 'remove-icon', aria: { hidden: true }) +
            tag.span(@view_context.t(:'blacklight.search.facets.selected.remove'), class: 'visually-hidden')
        end
    end + render_facet_count(classes: ['selected'])
  end

  private

    def facet_tooltip(key)
      FACET_TOOLTIPS.dig(@facet_item.facet_field, key)
    end

    FACET_TOOLTIPS = {
      'access_facet' => {
        'Free to Read' => I18n.t('blackcat.facet_tooltips.access_facet.free_to_read'),
        'Online' => I18n.t('blackcat.facet_tooltips.access_facet.online')
      }
    }.freeze
end
