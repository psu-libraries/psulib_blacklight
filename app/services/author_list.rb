# frozen_string_literal: true

# @abstract Interface to the author facet in Solr. Allows us to generate paginated lists of authors and the
# number of times they occur.

class AuthorList
  Entry = Struct.new(:value, :hits)

  attr_reader :length, :page, :prefix

  delegate :empty?, to: :entries

  def initialize(params = {})
    @page = params.fetch(:page, 1).to_i
    @length = params.fetch(:length, 10).to_i
    @prefix = params[:prefix]
  end

  def entries
    displayed = last_page? ? items : items.slice(0, (items.count - 1))

    displayed.map { |entry| Entry.new(*entry) }
  end

  def last_page?
    items.count <= length
  end

  private

    def items
      @items ||= begin
        results = facet_query
        return [] unless results

        results.each_slice(2).to_a
      end
    end

    # @note Because Solr can't tell us how many total facet items there are, we add 1 to the length to see if there's
    # another page of results.
    def facet_query
      Blacklight
        .default_index
        .connection
        .get('select', params: {
               'rows' => '0',
               'facet' => 'true',
               'facet.sort' => 'index',
               'facet.limit' => length + 1,
               'facet.offset' => (page - 1) * length,
               'facet.field' => 'all_authors_facet',
               'facet.prefix' => prefix
             })
        .dig('facet_counts', 'facet_fields', 'all_authors_facet')
    end
end
