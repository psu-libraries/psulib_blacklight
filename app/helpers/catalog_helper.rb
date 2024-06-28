# frozen_string_literal: true

module CatalogHelper
  include Blacklight::CatalogHelperBehavior
  extend SearchLinksHelper

  # Makes a link to a catalog item.
  def bound_info(options = {})
    field_data = options[:value]

    contents = field_data.map do |item|
      json = JSON.parse item
      if json['bound_catkey'].nil?
        json['bound_title']
      else
        link = link_to json['bound_title'], "/catalog/#{json['bound_catkey']}"
        "#{json['bound_callnumber']}#{bound_format(json['bound_format'])} bound in " + link
      end
    end

    content_tag 'span', contents.join('<br>'), nil, false
  end

  def bound_format(bound_format)
    bound_format.present? ? " (#{bound_format})" : ''
  end

  # Links to subject facet for the hierarchical subjects
  def subjectify(options = {})
    SubjectifyService.new(options[:value]).content
  end

  # Given a list of items, displays each item on its own line
  def newline_format(options = {})
    content_tag 'span', options[:value].join('<br>'), nil, false
  end

  # Turns NNNNNN into HH:MM:SS, attached to duration_ssm
  def display_duration(options = {})
    options[:value]&.map { |v| v.scan(/([0-9]{2})/).join(':') }
  end

  # Make a link out of a url and text
  def generic_link(options = {})
    field_data = options[:value]
    contents = field_data.map do |item|
      json = JSON.parse item
      link_to json['text'], json['url']
    end
    content_tag 'span', contents.join('<br>'), nil, false
  end

  # To render format icon on search results as the default thumbnail for now
  def render_thumbnail(document, _options = {})
    isbn_values = document.fetch(:isbn_valid_ssm, [])
    oclc_values = document.fetch(:oclc_number_ssim, [])
    lccn_values = document.fetch(:lccn_ssim, [])

    if isbn_values.empty? && oclc_values.empty? && lccn_values.empty?
      content_tag(:span, '',
                  class: "fas fa-responsive-sizing faspsu-#{document[:format][0].parameterize}")
    else
      content_tag(:span, '',
                  class: "fas fa-responsive-sizing faspsu-#{document[:format][0].parameterize}",
                  data: { isbn: isbn_values,
                          oclc: oclc_values,
                          lccn: lccn_values,
                          type: 'bibkeys' })
    end
  end

  def oclc_number(document)
    document.fetch(:oclc_number_ssim, [])&.first
  end

  def marc_record_details(document)
    details = []
    details.push link_to(
      'View MARC record',
      marc_view_path(document[:id]), id: 'marc_record_link'
    )
    details.push "catkey: #{document[:id]}"
    safe_join(details, ' | ')
  end

  # Returns suitable argument to options_for_select method, to create
  # an html select based on #search_field_list with labels for search
  # bar only. Skips search_fields marked :include_in_simple_select => false
  def search_bar_select
    blacklight_config.search_fields.map do |_key, field_def|
      if should_render_field?(field_def)
        [
          field_def.dropdown_label ||
            field_def.label, field_def.key, { 'data-placeholder' => placeholder_text(field_def) }
        ]
      end
    end.compact
  end

  def placeholder_text(field_def)
    if field_def.respond_to?(:placeholder_text)
      field_def.placeholder_text
    else
      t('blacklight.search.form.search.placeholder')
    end
  end
end
