# frozen_string_literal: true

class Browse::BrowseControls < ViewComponent::Base
  attr_reader :prev_item, :next_item, :params

  def initialize(prev_item:, next_item:, params:)
    @prev_item = prev_item
    @next_item = next_item
    @params = params
  end
end
