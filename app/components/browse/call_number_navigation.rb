# frozen_string_literal: true

module Browse
  class CallNumberNavigation < Navigator
    delegate :next_item, :previous_item, to: :list

    def previous_path
      browse_path(ending: previous_item.key, length: length)
    end

    def next_path
      browse_path(starting: next_item.key, length: length)
    end

    def next_title
      "(starts with #{next_item.call_number})"
    end

    def previous_title
      "(ends with #{previous_item.call_number})"
    end

    def previous?
      previous_item.present?
    end

    def next?
      next_item.present?
    end

    def length
      params[:length]
    end
  end
end
