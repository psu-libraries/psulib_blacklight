# frozen_string_literal: true

# @abstact Creates a fake marc-like Solr record

class RecordFactory
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
      forward_lc_shelfkey: forward_shelfkey,
      reverse_lc_shelfkey: reverse_shelfkey,
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

    def forward_shelfkey
      ShelfList.generate_forward_shelfkey(call_number)
    end

    def reverse_shelfkey
      ShelfList.generate_reverse_shelfkey(call_number)
    end
end
