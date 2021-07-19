# frozen_string_literal: true

# @abstract Returns a set of Solr documents for a given call number query.

class ShelfList
  FORWARD_CHARS = ('0'..'9').to_a + ('A'..'Z').to_a
  CHAR_MAP = FORWARD_CHARS.zip(FORWARD_CHARS.reverse).to_h

  def self.call(args)
    new(args).documents
  end

  def self.generate_reverse_shelfkey(key)
    generate_forward_shelfkey(key)
      .chars
      .map { |char| CHAR_MAP.fetch(char, char) }
      .append('~')
      .join
  end

  def self.generate_forward_shelfkey(call_number)
    Lcsort.normalize(call_number) || call_number
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

  def documents
    {
      after: forward.map { |key| document_query(field: forward_shelfkey, value: key) }.flatten,
      before: reverse.map { |key| document_query(field: reverse_shelfkey, value: key) }.flatten
    }
  end

  def forward
    terms_query(field: forward_shelfkey, limit: forward_limit)
      .each_slice(2)
      .map(&:first)
  end

  def reverse
    terms_query(field: reverse_shelfkey, value: self.class.generate_reverse_shelfkey(query), limit: reverse_limit)
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

  # @todo Convert this query to:
  #
  #   q: "shelfkey:(FA.0100083.B466.1915 FA.0100772.O787.2001 FA.0101298.J306.1963 FA.0102233.S992.1844)"
  #   defType: 'lucene'
  #
  # Because the order isn't predicable, we'll need to re-sort it according to the shelfkey order returned in the terms
  # query
  def document_query(field:, value:)
    Blacklight
      .default_index
      .connection
      .get('select', params: { 'q' => "#{field}:#{value}" })
      .dig('response', 'docs')
      .map { |document| SolrDocument.new(document) }
  end
end
