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
        "#{json['bound_callnumber']} (#{json['bound_format']}) bound in " + link
      end
    end

    content_tag 'span', contents.join('<br>'), nil, false
  end

  SEPARATOR = '—'
  QUERYSEP = '—'
  # Links to subject facet for the hierarchical subjects
  def subjectify(options = {})
    result = []
    all_subjects = []
    sub_array = []
    options[:value].each_with_index do |subject, i|
      spl_sub = subject.split(QUERYSEP)
      sub_array << []
      subject_accum = ''
      spl_sub.each_with_index do |subsubject, j|
        spl_sub[j] = subject_accum + subsubject
        subject_accum = spl_sub[j] + QUERYSEP
        sub_array[i] << spl_sub[j]
      end
      all_subjects[i] = subject.split(QUERYSEP)
    end
    options[:value].each_with_index do |_subject, i|
      lnk = ''
      lnk_accum = ''
      all_subjects[i].each_with_index do |subsubject, j|
        lnk = lnk_accum + link_to(subsubject,
                                  "/?f[subject_facet][]=#{CGI.escape sub_array[i][j]}",
                                  class: 'search-subject', title: "Search: #{sub_array[i][j]}")
        lnk_accum = lnk + content_tag(:span, SEPARATOR, class: 'subject-level')
      end
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
end
