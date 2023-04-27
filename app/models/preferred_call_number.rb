# frozen_string_literal: true

module PreferredCallNumber
  def preferred_call_number
    if call_number_lc
      call_number_lc
    elsif call_number_dewey
      call_number_dewey
    end
  end

  def preferred_classification
    if call_number_lc
      'lc'
    elsif call_number_dewey
      'dewey'
    end
  end

  private

    def call_number_dewey
      @_source['call_number_dewey_ssm']
    end

    def call_number_lc
      @_source['call_number_lc_ssm']
    end
end
