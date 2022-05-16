# frozen_string_literal: true

class ShelfKey
  def self.normalized(call_number)
    Lcsort.normalize(call_number) || call_number.upcase.gsub(/ /, '.')
  end
end
