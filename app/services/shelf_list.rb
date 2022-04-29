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
      after: shelf_items(documents: forward_docs, direction: 'forward'),
      before: shelf_items(documents: reverse_docs, direction: 'reverse')
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
    def shelf_items(documents:, direction:)
      return [] if documents.empty?

      # If a record has multiple callnumbers, get the most relevant/closest key to the query
      keys = documents.map do |document|
        closest_shelfkey(keys: document.fetch(shelfkey_field), direction: direction)
      end.uniq

      holdings = Holdings.new(documents, shelfkey_field)
      keys.map do |key|
        holdings.find(key)
      end
    end

    def closest_shelfkey(keys:, direction:)
      return keys.first if keys.length == 1

      # exact match
      return query if keys.include?(query)

      # When there are multiple keys matching the first char with query's first char,
      # prefers the closest distance key
      # When there are no keys matching the initials, select the key whose first char is
      # closest to the query's first char
      initial_matched_closest_key(keys) || closest_key(keys, direction)
    end

    def closest_key(keys, direction)
      query_initial = query[first_char_pos]

      keys
        .select do |key|
        key_initial = key[first_char_pos]
        direction == 'forward' ? key_initial > query_initial : query_initial > key_initial
      end
        .index_with { |key| (query_initial.ord - key[first_char_pos].ord).abs }
        .min_by { |_key, distance| distance }
        .first
    end

    def initial_matched_closest_key(keys)
      keys
        .select { |key| key[first_char_pos] == query[first_char_pos] }
        &.index_with { |key| DidYouMean::Levenshtein.distance(key, query) }
        &.min_by { |_key, distance| distance }
        &.first
    end

    def first_char_pos
      classification == 'dewey' ? 3 : 0
    end

    def forward_query
      if @forward_docs.empty?
        query
      else
        closest_shelfkey(keys: @forward_docs.last[shelfkey_field], direction: 'forward')
      end
    end

    def reverse_query
      if @reverse_docs.empty?
        query
      else
        closest_shelfkey(keys: @reverse_docs.first[shelfkey_field], direction: 'reverse')
      end
    end
end
