# frozen_string_literal: true

module HathiLinks
  def hathi_links
    return nil unless oclc_number.present?

    {
      text: ht_link_text,
      url: ht_url,
      hathitrust: hathitrust?
    }
  end

  private

    def ht_access
      @_source['ht_access_ss']
    end

    def ht_url
      return "https://catalog.hathitrust.org/api/volumes/oclc/#{oclc_number}.html" if hathitrust?

      "https://google.com/books?vid=OCLC#{oclc_number}"
    end

    def ht_link_text
      return I18n.t('blackcat.hathitrust.public_domain_text') if hathitrust?

      I18n.t('blackcat.hathitrust.alt_hathi_text')
    end

    def hathitrust?
      ht_access == 'allow'
    end

    def oclc_number
      @_source['oclc_number_ssim']&.first
    end
end
