module ClauseCountLimiter
  # Limits the number of clauses allowed in a search field. Varies by search field type.
  def limit_clause_count(solr_parameters)
    return unless is_query_present?(solr_parameters)

    length = case blacklight_params['search_field']
             when 'all_fields'
               # 10 terms, 1 will be added while truncating
               10
             when 'title'
               # 27 terms + "edismax", "qf", "title_qf", "pf", "title_pf", "pf3", "title_pf3", "pf2", "title_pf2"
               36
             when 'author'
               # 27 terms + "edismax", "qf", "author_qf", "pf", "author_pf", "pf3", "author_pf3", "pf2", "author_pf2"
               36
             when 'subject'
               # 6 + "edismax",  "qf", "subject_qf", "pf", "subject_pf", "pf3", "subject_pf3", "pf2", "subject_pf2"
               15
             when 'isbn_issn'
               # 9 + "edismax", "qf", "isbn_issn_qf", "pf", "pf3", "pf2"
               15
             else
               # 20 fallback for any other search field such as publisher, series_statement,
               # work_entry and genre_headings
               20
             end

    truncate_query(solr_parameters, length) unless blacklight_params['search_field'] == 'call_number'
  end

  private

    def is_query_present?(solr_parameters)
      solr_parameters[:q].present? && blacklight_params[:q].present?
    end

    def get_query_length(solr_parameters)
      solr_parameters[:q].split(/\b/).select { |x| x.match?(/\w/) }.length
    end

    def truncate_query(solr_parameters, length)
      solr_parameters[:q] = solr_parameters[:q].truncate_words(length + 1, separator: /\W+/, omission: '') unless
      get_query_length(solr_parameters) <= length
    end
end
