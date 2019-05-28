# frozen_string_literal: true

class PsulIndexPresenter < Blacklight::IndexPresenter
  def fields
    original = super
    # Hide label for these fields
    ['author_person_display_ssm',
     'author_corp_display_ssm',
     'author_meeting_display_ssm',
     'format',
     'publication_display_ssm',
     'edition_display_ssm'].each { |f| configuration.index_fields[f].label = nil }

    original
  end
end
