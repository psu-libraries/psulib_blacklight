# frozen_string_literal: true

class HathiLinks
  attr_reader :document

  def initialize(document)
    @document = document
    @ht_hash = ht_hash
  end

  def ht_hash
    JSON.parse(document['hathitrust_struct']&.first)
  end

  def id
    ht_hash['ht_id']
  end

  def bib_key
    ht_hash['ht_bib_key']
  end

  def access
    ht_hash['access']
  end

  def url
    url = if id.present?
            I18n.t('blackcat.hathitrust.mono_url') + id
          else
            I18n.t('blackcat.hathitrust.multi_url') + bib_key
          end

    url += I18n.t('blackcat.hathitrust.url_append') if etas_item?
    url
  end

  def link_text
    text = I18n.t('blackcat.hathitrust.public_domain_text') if access == 'allow'
    text = I18n.t('blackcat.hathitrust.restricted_access_text') if access == 'deny' && !Settings&.hathi_etas
    text = I18n.t('blackcat.hathitrust.etas_text') if etas_item?
    text
  end

  def additional_text
    return unless etas_item?

    I18n.t('blackcat.hathitrust.etas_additional_text')
  end

  def etas_item?
    access == 'deny' && Settings&.hathi_etas
  end
end
