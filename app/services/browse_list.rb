# frozen_string_literal: true

# @abstract Interface to facet fields in Solr. Allows us to generate paginated lists of facet terms and the number of
# times they occur.

class BrowseList
  Entry = Struct.new(:value, :hits)

  attr_reader :length, :page, :prefix, :field

  delegate :empty?, to: :entries

  def initialize(field:, page: 1, length: 10, prefix: nil)
    @field = field
    @page = page.to_i
    @length = length.to_i
    @prefix = prefix
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
               'facet.field' => field,
               'facet.prefix' => prefix
             })
        .dig('facet_counts', 'facet_fields', field)
    end
end
