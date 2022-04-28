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

  attr_reader :query, :forward_limit, :reverse_limit, :classification

  def initialize(
    query:,
    forward_limit:,
    reverse_limit:,
    classification:
  )
    @query = query
    @reverse_limit = (reverse_limit || 10).to_i
    @forward_limit = (forward_limit || 10).to_i
    @classification = classification
  end

  def build
    {
      after: shelf_items(forward_docs),
      before: shelf_items(reverse_docs)
    }
  end

  def shelfkey_field
    "#{classification}_shelfkey"
  end

  private

    def forward_docs
      params = ShelfParams.new(
        field: shelfkey_field,
        query: query
      )

      @forward_docs ||= ShelfQuery.call(
        limit: forward_limit,
        params: params
      )

      # Try to get more documents with the last document's shelfkey
      # if there aren't enough documents returned
      if @forward_docs.empty? || @forward_docs.length < forward_limit
        params = ShelfParams.new(
          field: shelfkey_field,
          query: forward_query,
          include_more: true
        )

        @forward_docs += ShelfQuery.call(
          limit: forward_limit,
          params: params
        )

        @forward_docs.uniq! do |doc|
          [doc['id'], doc[shelfkey_field.to_s]]
        end
      end

      @forward_docs || []
    end

    def reverse_docs
      params = ShelfParams.new(
        field: shelfkey_field,
        query: query,
        include_lower: true
      )

      @reverse_docs ||= ShelfQuery.call(
        limit: reverse_limit,
        params: params
      )

      # Try to get more documents with the first document's shelfkey
      # if there aren't enough documents returned
      if @reverse_docs.empty? || @reverse_docs.length < reverse_limit
        params = ShelfParams.new(
          field: shelfkey_field,
          query: reverse_query,
          include_lower: true,
          include_more: true
        )

        @reverse_docs += ShelfQuery.call(
          limit: reverse_limit,
          params: params
        )

        @reverse_docs.uniq! do |doc|
          [doc['id'], doc[shelfkey_field.to_s]]
        end
      end

      @reverse_docs || []
    end

    # @return Array<ShelfItem>
    # @note Uses a Holdings object to build a set of shelf item objects. The documents are already in the proper order.
    # Using Holdings, we construct a hash of every shelf key and its document.
    # There can be multiple documents per key, if the same call number is present in multiple items.
    def shelf_items(documents)
      return [] if documents.empty?

      keys = documents.map do |document|
        closest_shelfkey(document.fetch(shelfkey_field))
      end

      holdings = Holdings.new(documents, shelfkey_field)
      keys.map do |key|
        holdings.find(key)
      end
    end

    def closest_shelfkey(keys)
      return keys.first if keys.length == 1

      keys
        .index_with { |key| DidYouMean::Levenshtein.distance(key[0..7], query[0..7]) }
        .min_by { |_key, distance| distance }
        .first
    end

    def forward_query
      if @forward_docs.empty?
        query
      else
        @forward_docs.last[shelfkey_field].first
      end
    end

    def reverse_query
      if @reverse_docs.empty?
        query
      else
        @reverse_docs.first[shelfkey_field].first
      end
    end
end
