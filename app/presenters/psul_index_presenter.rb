# frozen_string_literal: true

class PsulIndexPresenter < Blacklight::IndexPresenter
  def fields
    original = super
    # To hide label for publication statement
    configuration.index_fields['publication_display_ssm'].label = nil
    configuration.index_fields['format'].label = nil

    original
  end
end
