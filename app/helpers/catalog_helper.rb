# frozen_string_literal: true

module CatalogHelper
  include Blacklight::CatalogHelperBehavior

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

  # Links to general subject search for other subjects
  def other_subjectify(options = {})
    result = []
    options[:value].each do |subject|
      lnk = link_to(subject,
                    "/?search_field=subject&q=#{CGI.escape subject}",
                    class: 'search-subject', title: "Search: #{subject}")
      result << content_tag('li', lnk, nil, false)
    end
    content_tag 'ul', result.join(''), nil, false
  end

  # Makes a link to genre full facet
  def genre_links(options = {})
    result = []

    options[:value].each do |genre|
      link = link_to genre, "/?f[genre_full_facet][]=#{CGI.escape genre}"
      result << content_tag('li', link, nil, false)
    end

    content_tag 'ul', result.join(''), nil, false
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

  # Links to series search for series
  def series_links(options = {})
    strict_titles = options[:document][:series_title_strict_tsim] || []
    result = []
    options[:value].zip(strict_titles).each do |series, strict_title|
      lnk = link_to(series,
                    "/?search_field=series&q=#{CGI.escape(strict_title || series)}",
                    class: 'search-series', title: "Search: #{strict_title || series}")
      result << content_tag('li', lnk, nil, false)
    end
    content_tag 'ul', result.join(''), nil, false
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

  # Makes a link to title search
  def title_links(options = {})
    result = options[:value].map do |serial_title|
      link = link_to serial_title, "/?search_field=title&q=#{CGI.escape serial_title}"
      content_tag('li', link, nil, false)
    end

    content_tag 'ul', result.join(''), nil, false
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

  def get_first_only(options = {})
    options[:value].first
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

  def search_bar_field
    case params[:action]
    when 'call_numbers'
      case params[:classification]
      when 'lc'
        'browse_lc'
      when 'dewey'
        'browse_dewey'
      end
    when 'authors'
      'browse_authors'
    when 'subjects'
      'browse_subjects'
    when 'titles'
      'browse_titles'
    else
      params[:search_field]
    end
  end
end
