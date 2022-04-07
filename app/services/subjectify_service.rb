# frozen_string_literal: true

class SubjectifyService
  attr_accessor :subjects, :subject_array, :li_content

  def initialize(subjects)
    @subjects = subjects
    @subject_array = []
    @li_content = []
  end

  SEPARATOR = '—'
  QUERYSEP = '—'

  def content
    generate_li_content
    helpers.content_tag 'ul', li_content.join(''), nil, false
  end

  private

    def generate_li_content
      subjects.each_with_index do |subject, i|
        append_subject_array(split_subject(subject), i)
        append_li_content(split_subject(subject), i)
      end
    end

    def append_li_content(split_subject, index)
      lnk = ''
      lnk_accum = ''
      split_subject.each_with_index do |subsubject, j|
        lnk = lnk_accum + helpers.link_to(subsubject,
                                          "/?f[subject_facet][]=#{CGI.escape subject_array[index][j]}",
                                          class: 'search-subject', title: "Search: #{subject_array[index][j]}")
        lnk_accum = lnk + helpers.content_tag(:span, SEPARATOR, class: 'subject-level')
      end
      li_content << helpers.content_tag('li', lnk, nil, false)
    end

    def append_subject_array(split_subject, index)
      subject_array << []
      subject_accum = ''
      split_subject.each do |subsubject|
        accum_and_subsub = subject_accum + subsubject
        subject_accum = accum_and_subsub + QUERYSEP
        subject_array[index] << accum_and_subsub
      end
    end

    def split_subject(subject)
      subject.split(QUERYSEP)
    end

    def helpers
      ActionController::Base.helpers
    end
end
