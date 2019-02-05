# frozen_string_literal: true

class PsulIndexPresenter < Blacklight::IndexPresenter
  def label(field_or_string_or_proc, opts = {})
    original = super
    # To hide label for publication statement
    @configuration.index_fields['publication_display_ssm'].label = nil

    original
  end
end
