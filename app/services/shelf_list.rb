# frozen_string_literal: true

# @abstract Returns a set of Solr documents for a given call number query.

class ShelfList
  def self.call(call_number:)
    new(call_number).documents
  end

  attr_reader :query

  def initialize(query)
    @query = query
  end

  def documents
    forward_documents = forward.map { |key| document_query(field: 'forward_shelf_key_sim', value: key) }
    reverse_documents = reverse.map { |key| document_query(field: 'reverse_shelf_key_sim', value: key) }

    (reverse_documents.reverse + forward_documents).flatten
  end

  def forward
    terms_query(field: 'forward_shelf_key_sim')
      .each_slice(2)
      .map(&:first)
  end

  def reverse
    terms_query(field: 'reverse_shelf_key_sim', value: reverse_query)
      .each_slice(2)
      .map(&:first)
  end

  def reverse_query
    RecordFactory::CHAR_MAP.fetch(query, query)
  end

  def terms_query(field:, value: nil)
    value ||= query
    Blacklight
      .default_index
      .connection
      .get('terms', params: { 'terms' => true, 'terms.fl' => field, 'terms.lower' => value })
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
