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

    def generate_links(search_type, options)
      result = []
      options[:value].zip(strict_titles(search_type, options)).each do |item, zipped|
        lnk = link_to(item,
                      "/?#{search_query(search_type)}=#{CGI.escape(zipped || item)}",
                      class: search_html_class(search_type),
                      title: search_field?(search_type) && search_type != :title ? "Search: #{zipped || item}" : nil)
        result << content_tag('li', lnk, nil, false)
      end
      content_tag 'ul', result.join, nil, false
    end

    def search_field?(search_type)
      [:series, :title, :subject].include?(search_type)
    end

    def search_query(search_type)
      search_field?(search_type) ? "search_field=#{search_type}&q" : "f[#{search_type.to_s.concat('_facet')}][]"
    end

    def search_html_class(search_type)
      search_field?(search_type) && search_type != :title ? "search-#{search_type}" : nil
    end

    def strict_titles(search_type, options)
      search_type == :series ? options[:document][:series_title_strict_tsim] || [] : []
    end
end
