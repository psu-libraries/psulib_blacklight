# frozen_string_literal: true

# @abstact Creates a fake marc-like Solr record

class RecordFactory
  ALPHA = ('A'..'Z').to_a
  ARABC = ('0'..'9').to_a

  CHAR_MAP = ALPHA.zip(ALPHA.reverse).to_h.merge(ARABC.zip(ARABC.reverse).to_h)

  def initialize
    record
  end

  def record
    {
      id: id,
      oclc_number_ssim: id,
      title_display_ssm: Faker::Lorem.sentence,
      publication_display_ssm: Faker::Company.name,
      call_number_ssm: call_number,
      forward_shelf_key_sim: shelf_key,
      reverse_shelf_key_sim: reverse_shelf_key,
      format: formats.sample
    }
  end

  private

    def id
      @id ||= Faker::Number.leading_zero_number(digits: 10)
    end

    def call_number
      @call_number ||= lc_call_number
    end

    def formats
      %w(
        Book
        Government Document
        Journal/Periodical
        Audio
        Video
        Musical Score
      )
    end

    # @return String
    # @note generates an LC-ish call number like XX123.456 .X123 2001
    def lc_call_number
      [
        classification,
        cutter,
        year
      ].join(' ').upcase
    end

    def classification
      Faker::Alphanumeric.alpha(number: 2) + Faker::Number.decimal(l_digits: 3, r_digits: 3).to_s
    end

    def cutter
      ".#{Faker::Alphanumeric.alpha(number: 1)}#{Faker::Number.number(digits: 3)}"
    end

    def year
      Faker::Date.between(from: '1800-01-01', to: Date.today).year
    end

    def shelf_key
      Lcsort.normalize(call_number)
    end

    def reverse_shelf_key
      shelf_key
        .chars
        .map { |char| CHAR_MAP.fetch(char, char) }
        .join
    end
end
