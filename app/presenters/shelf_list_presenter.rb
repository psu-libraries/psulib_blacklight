# frozen_string_literal: true

class ShelfListPresenter
  MIN = 3
  MAX = 100
  DEFAULT = 10

  attr_reader :starting, :ending, :nearby

  def initialize(params = {})
    @starting = params[:starting]
    @ending = params[:ending]
    @nearby = params[:nearby]
    @length = params.fetch(:length, DEFAULT).to_i
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
    if beginning?
      documents.slice(0, length)
    else
      documents.slice(1, length)
    end
  end

  def next
    return if the_end?

    documents.last
  end

  def previous
    return if beginning?

    documents.first
  end

  class Item < SimpleDelegator
    attr_writer :match, :nearby

    def exact_match?
      @match || false
    end

    def nearby?
      @nearby || false
    end
  end

  private

    def documents
      (before_items + after_items)
    end

    def before_items
      before_list = shelf_list[:before].reverse.map { |item| Item.new(item) }

      return before_list if nearby.blank?

      if before_list.last.call_number == nearby
        before_list.last.match = true
      else
        before_list << Item.new(SolrDocument.new({ call_number_ssm: ["You're looking for: #{nearby}"] }))
        before_list.shift
      end

      before_list.last.nearby = true
      before_list
    end

    def after_items
      shelf_list[:after].map do |item|
        Item.new(item)
      end
    end

    def shelf_list
      @shelf_list ||= ShelfList.call(shelf_list_params)
    end

    def shelf_list_params
      if starting.present?
        { query: starting, forward_limit: length, reverse_limit: 2 }
      elsif ending.present?
        { query: ending, forward_limit: 1, reverse_limit: length + 1 }
      elsif nearby.present?
        { query: nearby, forward_limit: (length - MIN) + 2, reverse_limit: MIN }
      else
        { query: '0', forward_limit: length + 1, reverse_limit: 0 }
      end
    end

    def beginning?
      if ending.present?
        shelf_list[:before].length <= length
      else
        shelf_list[:before].empty?
      end
    end

    def the_end?
      starting.present? && shelf_list[:after].length < length
    end
end
