# frozen_string_literal: true

module ClauseCountLimiter
  # Limits the number of clauses allowed in a search field. Varies by search field type.
  def limit_clause_count(solr_parameters)
    return unless query_present?(solr_parameters)

    length = case blacklight_params['search_field']
             when 'all_fields'
               # 10 terms, 1 will be added while truncating
               10
             when 'title', 'author'
               # 27 terms + "edismax", "qf", "title/author_qf", "pf", "title/author_pf", "pf3", "title/author_pf3",
               # "pf2", "title/author_pf2"
               36
             when 'subject', 'isbn_issn'
               # 6 + "edismax",  "qf", "subject_qf", "pf", "subject_pf", "pf3", "subject_pf3", "pf2", "subject_pf2"
               # or # 9 + "edismax", "qf", "isbn_issn_qf", "pf", "pf3", "pf2"
               15
             else
               # 20 fallback for any other search field such as publisher, series_statement,
               # work_entry and genre_headings
               20
             end

    truncate_query(solr_parameters, length) unless blacklight_params['search_field'] == 'call_number'
  end

  private

    def query_present?(solr_parameters)
      solr_parameters[:q].present? && blacklight_params[:q].present?
    end

    def get_query_length(solr_parameters)
      solr_parameters[:q].split(/\b/).grep(/\w/).length
    end

    def truncate_query(solr_parameters, length)
      solr_parameters[:q] = solr_parameters[:q].truncate_words(length + 1, separator: /\W+/, omission: '') unless
      get_query_length(solr_parameters) <= length
    end
end
