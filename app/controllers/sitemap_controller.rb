# frozen_string_literal: true

class SitemapController < ApplicationController
  def index
    @access_list = access_list
  end

  def show
    @solr_response = Blacklight.default_index.connection.select(
      params:
            {
              q: "{!prefix f=hashed_id_si v=#{access_params}}}",
              defType: 'lucene',
              fl: 'id,timestamp',
              facet: false,
              rows: 3_000_000 # a sufficiently large number to prevent Solr from ever attempting paging
            }
    )
  end

  private

    def access_params
      params.require(:id) # :id collides with Solr id but they are different. This is the Sitemap ID.
    end

    def max_documents
      Rails.cache.fetch('index_max_docs', expires_in: 1.day) do
        Blacklight.default_index.connection.select(params: { q: '*:*', rows: 0 })['response']['numFound']
      end
    end

    def access_list
      average_chunk = [10000, max_documents].min # Sufficiently less than 50,000 max per sitemap
      access = (Math.log(max_documents / average_chunk) / Math.log(16)).ceil
      (0...(16**access))
        .to_a
        .map { |v| v.to_s(16).rjust(access, '0') }
    end
end
