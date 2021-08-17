# frozen_string_literal: true

# @abstract Returns a hash with two sets of ShelfItem objects for a given call number query. The sets are divided
# between those items that come after a given query parameter, and those that come before. The order of each is the raw
# order coming out of Solr.  Any additional processing or arrangement is left to whichever class or method is calling
# this service.

class ShelfList
  # @return [Hash]
  # @note Returns a hash of after and before list items.
  def self.call(args)
    new(args).build
  end

  attr_reader :query, :forward_limit, :reverse_limit, :forward_shelfkey, :reverse_shelfkey

  def initialize(
    query:,
    forward_limit:,
    reverse_limit:,
    forward_shelfkey: 'forward_lc_shelfkey',
    reverse_shelfkey: 'reverse_lc_shelfkey'
  )
    @query = query
    @reverse_limit = (reverse_limit || 10).to_i
    @forward_limit = (forward_limit || 10).to_i
    @forward_shelfkey = forward_shelfkey
    @reverse_shelfkey = reverse_shelfkey
  end

  def build
    {
      after: shelf_items(keys: forward_keys, shelfkey: forward_shelfkey, direction: 'forward'),
      before: shelf_items(keys: reverse_keys, shelfkey: reverse_shelfkey, direction: 'reverse')
    }
  end

  private

    def forward_keys
      @forward_keys ||= terms_query(field: forward_shelfkey, limit: forward_limit)
        .each_slice(2)
        .map(&:first)
    end

    def reverse_keys
      @reverse_keys ||= terms_query(
        field: reverse_shelfkey,
        value: ShelfKey.reverse(query),
        limit: reverse_limit
      )
        .each_slice(2)
        .map(&:first)
    end

    # @return Array<ShelfItem>
    # @note Uses a Holdings object to build a set of shelf item objects from #document_query. A set of documents is
    # retrieved from Solr for a given set of shelf keys. The keys are already in the proper order, we just need a
    # complete document for each one. Using Holdings, we construct a hash of every shelf key and its document from
    # #document_query.  There can be multiple documents per key, if the same call number is present in multiple items.
    def shelf_items(keys:, shelfkey:, direction:)
      return [] if keys.empty?

      documents = document_query(field: shelfkey, values: keys)
      holdings = Holdings.new(documents: documents, direction: direction)
      keys.map do |key|
        holdings.find(key)
      end
    end

    # @note The first Solr query used to get a listing of forward or reverse shelf keys for a given term query.
    def terms_query(field:, limit:, value: nil)
      return [] if limit.zero?

      Blacklight
        .default_index
        .connection
        .get('terms',
             params: {
               'terms' => true,
               'terms.lower.incl' => true,
               'terms.fl' => field,
               'terms.lower' => (value || query),
               'terms.limit' => limit,
               'terms.sort' => 'index'
             })
        .dig('terms', field) || []
    end

    # @note This is the second Solr query, performed after we've retrieved a listing of forward or reverse shelf keys.
    # Using a specific 'shelf' search handler, we retrieve all the documents for a given set of shelf keys, with a
    # pre-defined set of fields. Note that the max rows is set in the handler, so it is theoretically possible to NOT
    # get all of the records back for a given shelf key. But this seems unlikely as the shelf key would need to occur in
    # more documents than the max set in the handler.
    def document_query(field:, values:)
      Blacklight
        .default_index
        .connection
        .get('select',
             params: {
               'q' => "#{field}:(#{values.join(' ')})",
               'qt' => 'shelf'
             })
        .dig('response', 'docs')
    end
end
