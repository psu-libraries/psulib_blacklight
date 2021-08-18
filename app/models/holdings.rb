# frozen_string_literal: true

# @abstract Holdings is an intermediary data object that is used by the ShelfList service to build an array of ShelfItem
# objects. It is not currently used anywhere outside of the service. When querying for an ordered list of call numbers,
# we have to build a set of items based on the shelf keys returned from Solr. Because each Solr record can have multiple
# call numbers, which map to different shelf keys, and the same shelf key can exist in several Solr records, we need to
# denormalize the data into a set that we can render for our call number browse.
#
# @example A typical Holdings object will look like:
#
# >  holdings = Holdings.new(documents: [array of Solr Documents], direction: 'forward')
# => holdings.items
# {
#   'AB.1234Z--2001' => #<ShelfItem @call_number="AB .1234Z 2001", @key="AB.1234Z--2001", @documents=[solr_doc]>,
#   'D..4560X' => #<ShelfItem @call_number="D .456X", @key="D..4560X", @documents=[solr_doc1, solr_doc2]>
# }
#
# In the above example, each key of the items hash is a forward shelf key and is unique to the set of data. If an item
# in Solr has multiple call numbers, then it will appear multiple times within the items hash under a different key.
# Finally, if the same call number and key are found within the document set, the documents array of the shelf item for
# the key will reflect that.

class Holdings
  attr_reader :items

  # Solr fields pulled from the record for later use
  METADATA_FIELDS = %w(
    author_person_display_ssm
    edition_display_ssm
    format
    id
    library_facet
    overall_imprint_display_ssm
    publication_display_ssm
    title_display_ssm
  ).freeze

  # @param documents [Array<SolrDocument, Hash>] Solr documents or hash objects from a query
  # @param direction [String] The direction in which we're looking, either 'forward' or 'reverse'
  # @note Direction is used so that we don't add every shelf key to the items hash.
  def initialize(documents:, direction:)
    @items = {}
    build_item_list(documents, direction)
  end

  # @return [ShelfItem]
  # @note Uses a shelf key pulled from the keymap_struct Solr field based on the direction we want, either forward or
  # reverse.
  def find(key)
    items.fetch(key)
  end

  private

    # @note Builds a up a set of shelf items for every shelf key in the document set. If multiple documents exist for a
    # given key, the additional documents are added to the item's document list.
    def build_item_list(documents, direction)
      documents.map do |document|
        JSON.parse(document.fetch('keymap_struct', ['[]']).first).map do |keymap|
          key = keymap.fetch("#{direction}_key")
          items[key] ||= ShelfItem.new(
            call_number: keymap['call_number'],
            key: keymap['forward_key']
          )
          items[key].add(document.slice(*METADATA_FIELDS))
        end
      end
    end
end
