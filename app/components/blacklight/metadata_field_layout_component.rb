# frozen_string_literal: true

module Blacklight
  class MetadataFieldLayoutComponent < Blacklight::Component
    with_collection_parameter :field
    renders_one :label
    # rubocop:disable Lint/UnusedBlockArgument
    renders_many :values, (lambda do |index:, value: nil, &block|
      classes = [@value_class, "blacklight-#{@key}"]
      classes.join(' ')

      if @value_tag.nil?
        block&.call || value
      elsif block
        content_tag @value_tag, class: classes, &block
      else
        content_tag @value_tag, value, class: classes
      end
    end)
    # rubocop:enable Lint/UnusedBlockArgument

    # @param field [Blacklight::FieldPresenter]
    def initialize(field:, value_tag: 'dd', value_class: 'metadata-field')
      @field = field
      @key = @field.key.parameterize
      @value_tag = value_tag
      @value_class = value_class
    end
  end
end
