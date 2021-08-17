# frozen_string_literal: true

class ShelfKey
  FORWARD_CHARS = ('0'..'9').to_a + ('A'..'Z').to_a
  CHAR_MAP = FORWARD_CHARS.zip(FORWARD_CHARS.reverse).to_h

  def self.forward(call_number)
    Lcsort.normalize(call_number) || call_number.upcase.gsub(/ /, '.')
  end

  def self.reverse(key)
    forward(key)
      .chars
      .map { |char| CHAR_MAP.fetch(char, char) }
      .append('~')
      .join
  end
end
