# frozen_string_literal: true

module ExternalLinks
  class LinkComponent < ViewComponent::Base
    LinkStruct = Struct.new(:url, :notes, :prefix, :text)

    def initialize(item)
      @item = LinkStruct.new(item['url'], item['notes'], item['prefix'], item['text'])
    end

    delegate :url, :notes, :prefix, :text, to: :item

    private

      # @note this needs to be a reader so the delegation will work
      attr_reader :item
  end
end
