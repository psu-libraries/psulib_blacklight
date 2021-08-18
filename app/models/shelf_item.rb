# frozen_string_literal: true

# @abstract An item on a virtual "shelf" used for browsing. A single shelf item contains one or more SolrDocument
# objects depending on how many records have the same call number. Shelf items are constructing using Holdings via the
# ShelfList service.

class ShelfItem
  attr_reader :call_number, :documents, :key
  attr_accessor :match, :nearby

  def initialize(call_number:, key:, label: nil, nearby: false)
    @call_number = call_number
    @key = key
    @documents = []
    @label = label
    @match = false
    @nearby = nearby
  end

  def label
    @label || default_label
  end

  def match?
    @match
  end

  def nearby?
    @nearby
  end

  def add(document)
    @documents << DecoratedDocument.new(SolrDocument.new(document))
  end

  class DecoratedDocument < SimpleDelegator
    def location_display
      locations = self['library_facet']

      return nil if locations.blank?

      locations.length > 3 ? 'Multiple Locations' : locations.join(' / ')
    end
  end

  private

    def default_label
      return 'Unknown' if documents.empty?

      documents.first.fetch('title_display_ssm', 'No title found')
    end
end
