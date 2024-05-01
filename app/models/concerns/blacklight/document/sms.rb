# frozen_string_literal: true

# This module provides the body of an email export based on the document's semantic values
module Blacklight::Document::Sms
  # Return a text string that will be the body of the email
  def to_sms_text
    semantics = to_semantic_values
    body = []
    ['title', 'latin_title', 'author', 'corporate_author', 'conference_author',
     'published', 'edition', 'format', 'language'].each do |field|
      if semantics[field.to_sym].present?
        value = semantics[field.to_sym]
        label = "blacklight.sms.text.#{field}"
        body << I18n.t(label, value: value.join('; '))
      end
    end
    body.join("\n") unless body.empty?
  end
end
