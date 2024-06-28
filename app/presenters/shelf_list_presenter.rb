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
    @length.clamp(MIN, MAX)
  end

  def list
    if first? || nearby_first?(shelf_items)
      shelf_items.slice(0, length)
    else
      shelf_items.slice(1, length)
    end
  end

  def next_item
    return if last?

    if first? || nearby_first?(shelf_items)
      shelf_items[length]
    else
      shelf_items[length + 1] || list.last
    end
  end

  def previous_item
    return if first?

    if nearby_first?(shelf_items)
      shelf_items.second
    else
      shelf_items.first
    end
  end

  private

    def shelf_items
      (before_items + after_items)
    end

    def shelvit_nearby
      if classification == 'dewey' && nearby.present?
        DEWEY_SHELF_PREFIX + nearby
      else
        nearby
      end
    end

    def shelf_key
      @shelf_key ||= Shelvit.normalize(shelvit_nearby) || nearby
    end

    # @return [Array<ShelfItem>]
    # @note If we're looking for something nearby on the shelf, and our query is an exact match
    # for that item, mark it accordingly. Otherwise, insert a placeholder shelf item that indicates
    # where the item would appear if it existed.
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

    def nearby_first?(list)
      list.first.call_number == 'None'
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
    #    Return only the items after the given key. A '' query starts at the very beginning of the list.
    def shelf_list_params
      if starting.present?
        { query: starting, forward_limit: length, reverse_limit: 2 }
      elsif ending.present?
        { query: ending, forward_limit: 1, reverse_limit: length + 1 }
      elsif shelf_key.present?
        { query: CGI.escape(shelf_key), forward_limit: (length - MIN) + 2, reverse_limit: MIN }
      else
        { query: query_to_first_page, forward_limit: length + 1, reverse_limit: 0 }
      end
        .merge!(classification: classification)
    end

    def query_to_first_page
      case classification
      when 'lc'
        'A'
      when 'dewey'
        "#{DEWEY_SHELF_PREFIX}0"
      else
        '0'
      end
    end

    def query_to_last_page
      case classification
      when 'lc'
        'Z'
      when 'dewey'
        "#{DEWEY_SHELF_PREFIX}9"
      else
        '0'
      end
    end

    def first_page?
      before_list.first.key.first.upcase == query_to_first_page
    end

    def last_page?
      shelf_list[:after].last.key.first.upcase == query_to_last_page
    end

    def first?
      return true if shelf_list[:before].empty?

      ending.present? && first_page? && shelf_list[:before].length <= length
    end

    def last?
      return true if shelf_list[:after].empty?

      starting.present? && last_page? && shelf_list[:after].length <= length
    end
end
