# frozen_string_literal: true

# @abstract Returns a set of Solr documents for a given call number query.

class ShelfList
  FORWARD_CHARS = ('0'..'9').to_a + ('A'..'Z').to_a
  CHAR_MAP = FORWARD_CHARS.zip(FORWARD_CHARS.reverse).to_h

  def self.call(args)
    new(args).documents
  end

  def self.reverse_shelfkey(key)
    forward_shelfkey(key)
      .chars
      .map { |char| CHAR_MAP.fetch(char, char) }
      .append('~')
      .join
  end

  def self.forward_shelfkey(call_number)
    Lcsort.normalize(call_number) || call_number
  end

  attr_reader :query, :forward_limit, :reverse_limit

  def initialize(query:, forward_limit:, reverse_limit:)
    @query = query
    @reverse_limit = (reverse_limit || 10).to_i
    @forward_limit = (forward_limit || 10).to_i
  end

  def documents
    {
      after: forward.map { |key| document_query(field: 'forward_shelfkey_sim', value: key) }.flatten,
      before: reverse.map { |key| document_query(field: 'reverse_shelfkey_sim', value: key) }.flatten
    }
  end

  def forward
    terms_query(field: 'forward_shelfkey_sim', limit: forward_limit)
      .each_slice(2)
      .map(&:first)
  end

  def reverse
    terms_query(field: 'reverse_shelfkey_sim', value: self.class.reverse_shelfkey(query), limit: reverse_limit)
      .each_slice(2)
      .map(&:first)
  end

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
             'terms.limit' => limit
           })
      .dig('terms', field) || []
  end

  def document_query(field:, value:)
    Blacklight
      .default_index
      .connection
      .get('select', params: { 'q' => "#{field}:#{value}" })
      .dig('response', 'docs')
      .map { |document| SolrDocument.new(document) }
  end
end
