# frozen_string_literal: true

# @abstract An item on a virtual "shelf" used for browsing. A single shelf item contains one or more SolrDocument
# objects depending on how many records have the same call number. Shelf items are constructing using Holdings via the
# ShelfList service.

class ShelfItem
  attr_reader :call_number, :documents, :key
  attr_accessor :match, :nearby

  def initialize(call_number:, key:, label: nil, nearby: false, key_field: nil)
    @call_number = call_number
    @key = key
    @documents = []
    @label = label
    @match = false
    @nearby = nearby
    @key_field = key_field
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

  def more_call_numbers
    all_shelfkeys
      .reject! { |shelfkey| shelfkey == key }

    return if all_shelfkeys.empty?

    keymap
      .select { |cn| all_shelfkeys.include?(cn['forward_key']) }
      .map { |cn| cn['call_number'] }
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

    def keymap
      JSON.parse(documents.first.fetch('keymap_struct', ['[]']).first)
    end

    def all_shelfkeys
      documents.first.fetch(@key_field)
    end

    def default_label
      return 'Unknown' if documents.empty?

      documents.first.fetch('title_display_ssm', 'No title found')
    end
end
