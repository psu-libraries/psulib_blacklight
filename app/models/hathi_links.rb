# frozen_string_literal: true

module HathiLinks
  def hathi_links
    return nil unless has_hathi_links?

    {
      text: ht_link_text,
      url: ht_url,
      additional_text: ht_additional_text
    }
  end

  private

    def has_hathi_links?
      @_source['hathitrust_struct'].present?
    end

    def hathi_links_field
      @_source['hathitrust_struct']
    end

    def ht_hash
      JSON.parse(hathi_links_field&.first)
    end

    def ht_id
      ht_hash['ht_id']
    end

    def ht_bib_key
      ht_hash['ht_bib_key']
    end

    def ht_access
      ht_hash['access']
    end

    def ht_url
      url = if ht_id.present?
              I18n.t('blackcat.hathitrust.mono_url') + ht_id
            else
              I18n.t('blackcat.hathitrust.multi_url') + ht_bib_key
            end

      url += I18n.t('blackcat.hathitrust.url_append') if etas_item?
      url
    end

    def ht_link_text
      I18n.t('blackcat.hathitrust.public_domain_text') if ht_access == 'allow'
      I18n.t('blackcat.hathitrust.restricted_access_text') if ht_access == 'deny' && !Settings&.hathi_etas

      I18n.t('blackcat.hathitrust.etas_text') if etas_item?
    end

    def ht_additional_text
      return nil unless etas_item?

      I18n.t('blackcat.hathitrust.etas_additional_text')
    end

    def etas_item?
      ht_access == 'deny' && Settings&.hathi_etas
    end
end
