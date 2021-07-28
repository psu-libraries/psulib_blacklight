# frozen_string_literal: true

class Browse::PageNavigation < ViewComponent::Base
  attr_reader :prev_item, :next_item, :length

  def initialize(prev_item:, next_item:, length:)
    @prev_item = prev_item
    @next_item = next_item
    @length = length
  end
end
