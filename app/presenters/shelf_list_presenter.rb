# frozen_string_literal: true

# @abstract Creates a virtual "shelf" of ShelfItem objects arranged in call number order based on a query parameter that
# is processed by our ShelfList service. The length of the shelf, and which call numbers you want to start, end, or look
# near, are parameters passed in to the presenter.

class ShelfListPresenter
  MIN = 3
  MAX = 100
  DEFAULT = 20
  DEWEY_SHELF_PREFIX = 'AAA'

  attr_reader :starting, :ending, :nearby, :classification

  delegate :empty?, to: :list

  def initialize(params = {})
    @starting = params[:starting]
    @ending = params[:ending]
    @nearby = params[:nearby]
    @length = params.fetch(:length, DEFAULT).to_i
    @classification = params[:classification]
  end

  def length
    if @length > MAX
      MAX
    elsif @length < MIN
      MIN
    else
      @length
    end
  end

  def list
    if first?
      shelf_items.slice(0, length)
    else
      shelf_items.slice(1, length)
    end
  end

  def next_item
    return if last?

    shelf_items.last
  end

  def previous_item
    return if first?

    shelf_items.first
  end

  private

    def shelf_items
      (before_items + after_items)
    end

    def shelvit_key
      if classification == 'dewey' && nearby.present?
        DEWEY_SHELF_PREFIX + nearby
      else
        nearby
      end
    end

    def shelf_key
      @shelf_key ||= Shelvit.normalize(shelvit_key) || nearby
    end

    # @return [Array<ShelfItem>]
    # @note The items coming before a particular call number are determined using a reverse shelf key, which means the
    # items are returned in a "reverse" order. To create a natural reading list, we need to reverse the reversed list
    # before adding it to our virtual shelf. If we're looking for something nearby on the shelf, and our query is an
    # exact match for that item, mark it accordingly. Otherwise, insert a placeholder shelf item that indicates where
    # the item would appear if it existed.
    def before_items
      list = before_list

      return list if shelf_key.blank?

      if match?
        match_item list
      else
        nearby_item list
      end
    end

    # @return [Array<ShelfItem>]
    def after_items
      shelf_list[:after].reject do |shelf_item|
        before_items.map(&:key).include? shelf_item.key
      end
    end

    def match?
      before_list
        &.map(&:key)
        &.include?(shelf_key)
    end

    def match_item(list)
      list.select do |shelf_item|
        if shelf_item.key == shelf_key
          shelf_item.match = true
          shelf_item.nearby = true if before_list.count.positive?
        end
      end

      list
    end

    def nearby_item(list)
      list << ShelfItem.new(label: "You're looking for: #{nearby}",
                            call_number: 'None',
                            key: nil)
      list.shift if list.count > 1
      list.last.nearby = true if list.count.positive?

      list
    end

    def before_list
      shelf_list[:before].reverse
    end

    def shelf_list
      @shelf_list ||= ShelfList.call(shelf_list_params)
    end

    # @note There are four possible scenarios, each determined by the parameters given to the presenter, and each
    # resulting in a specific set of arguments passed to the ShelfList service.
    #
    # 1) Querying from a known point forward:
    #    Returns a set of shelf items after a given key. The two items returned before the key are the item itself, and
    #    the previous item which is used to construct the link to the previous shelf.
    # 2) Querying from a known point backwards:
    #    Returns a set of shelf items before a given key. The one item that occurs after the key is used to construct
    #    the link to the next shelf.
    # 3) Looking from something nearby on the shelf, which may _or_ may not exist:
    #    Returns a set of shelf items such that the item we're looking for occurs *third* on the shelf. This is
    #    basically padding the results based on our minimum shelf length.
    # 4) Starting from the very beginning:
    #    Return only the items after the given key. A '0' query starts at the very beginning of the list.
    def shelf_list_params
      if starting.present?
        { query: starting, forward_limit: length, reverse_limit: 2 }
      elsif ending.present?
        { query: ending, forward_limit: 1, reverse_limit: length + 1 }
      elsif shelf_key.present?
        { query: shelf_key, forward_limit: (length - MIN) + 2, reverse_limit: MIN }
      else
        { query: '0', forward_limit: length + 1, reverse_limit: 0 }
      end
        .merge!(classification: classification)
    end

    def first?
      if ending.present?
        shelf_list[:before].length <= length
      else
        shelf_list[:before].empty?
      end
    end

    def last?
      starting.present? && shelf_list[:after].length < length
    end
end
