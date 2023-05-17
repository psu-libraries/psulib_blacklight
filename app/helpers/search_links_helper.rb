# frozen_string_literal: true

module SearchLinksHelper
  # Makes a link to genre full facet
  def genre_links(options = {})
    generate_links(:genre_full, options)
  end

  # Makes a link to thesis_department facet
  def thesis_dept_links(options = {})
    generate_links(:thesis_dept, options)
  end

  # Links to general subject search for other subjects
  def other_subjectify(options = {})
    generate_links(:subject, options)
  end

  # Links to series search for series
  def series_links(options = {})
    generate_links(:series, options)
  end

  # Makes a link to title search
  def title_links(options = {})
    generate_links(:title, options)
  end

  private

  def generate_links(link_type, options)
    result = []
    options[:value].zip(strict_titles(link_type, options)).each do |item, zipped|
      lnk = link_to(item,
                    "/?#{search_type(link_type)}=#{CGI.escape(zipped || item)}",
                    class: title_search_html_class(link_type), 
                    title: search_field?(link_type) && link_type != :title ? "Search: #{zipped || item}" : nil)
      result << content_tag('li', lnk, nil, false)
    end
    content_tag 'ul', result.join, nil, false
  end

  def search_field?(link_type)
    [:series, :title, :subject].include?(link_type)
  end

  def search_type(link_type)
    search_field?(link_type) ? "search_field=#{link_type.to_s}&q" : "f[#{link_type.to_s.concat("_facet")}][]"
  end

  def title_search_html_class(link_type)
    search_field?(link_type) && link_type != :title ? "search-#{link_type.to_s}" : nil
  end

  def strict_titles(link_type, options)
    link_type == :series ? options[:document][:series_title_strict_tsim] || [] : []
  end
end
