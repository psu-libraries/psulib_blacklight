# frozen_string_literal: true

module HathiLinks
  def hathi_links
    return nil if ht_access.blank?

    {
      text: ht_link_text,
      url: ht_url,
      additional_text: ht_additional_text,
      etas_item: etas_item?
    }
  end

  private

    def ht_access
      @_source['ht_access_ss']
    end

    def ht_url
      ocn = @_source['oclc_number_ssim'].first
      suffix = etas_item? ? I18n.t('blackcat.hathitrust.url_append') : ''
      "https://catalog.hathitrust.org/api/volumes/oclc/#{ocn}.html#{suffix}"
    end

    def ht_link_text
      return I18n.t('blackcat.hathitrust.public_domain_text') if ht_access == 'allow'
      return I18n.t('blackcat.hathitrust.restricted_access_text') unless etas_item?

      I18n.t('blackcat.hathitrust.etas_text')
    end

    def ht_additional_text
      return nil unless etas_item?

      I18n.t('blackcat.hathitrust.etas_additional_text')
    end

    def etas_item?
      ht_access == 'deny' && Settings&.hathi_etas
    end
end
