# frozen_string_literal: true

module ApplicationHelper
  # Makes a link to a catalog item.
  def catalog_link(options = {})
    field_data = options[:value].first
    field_data = JSON.parse field_data

    link_to field_data['linktext'], "/catalog/#{field_data['catkey']}"
  end

  # Turns NNNNNN into HH:MM:SS, attached to duration_ssm
  def display_duration(options = {})
    options[:value]&.map { |v| v.scan(/([0-9]{2})/).join(':') }
  end
  
  SEPARATOR = '—'
  QUERYSEP = '—'
  def subjectify(args)
    all_subjects = []
    sub_array = []
    args[:document][args[:field]].each_with_index do |subject, i|
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
    args[:document][args[:field]].each_with_index do |_subject, i|
      lnk = ''
      lnk_accum = ''
      all_subjects[i].each_with_index do |subsubject, j|
        lnk = lnk_accum + link_to(subsubject,
                                  "/?f[subject_facet][]=#{CGI.escape sub_array[i][j]}",
                                  class: 'search-subject',
                                  'data-toggle' => 'tooltip',
                                  'data-original-title' => "Search: #{sub_array[i][j]}",
                                  title: "Search: #{sub_array[i][j]}")
        lnk_accum = lnk + content_tag(:span, SEPARATOR) # , class: 'subject-level'
      end
      args[:document][args[:field]][i] = lnk.html_safe
    end
  end
end
