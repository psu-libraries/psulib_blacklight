# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HathiLinks do
  describe '#hathi_links' do
    context 'when no OCLC number is present' do
      it 'returns nil' do
        document = { 'oclc_number_ssim': nil }
        hathi_link = SolrDocument.new(document).hathi_links

        expect(hathi_link).not_to be_present
      end
    end

    context 'when OCLC number is present' do
      context 'when the record access is "allow"' do
        it 'generates a url to hathitrust' do
          document = { 'oclc_number_ssim': ['12345'],
                       'ht_access_ss': 'allow' }
          hathi_link = SolrDocument.new(document).hathi_links

          expect(hathi_link).to match({
                                        text: I18n.t('blackcat.hathitrust.public_domain_text'),
                                        url: 'https://catalog.hathitrust.org/api/volumes/oclc/12345.html',
                                        hathitrust: true
                                      })
        end
      end

      context 'when the record access is "deny"' do
        it 'generates a url to google books' do
          document = { 'oclc_number_ssim': ['12345'],
                       'ht_access_ss': 'deny' }
          hathi_link = SolrDocument.new(document).hathi_links

          expect(hathi_link).to match({
                                        text: I18n.t('blackcat.hathitrust.alt_hathi_text'),
                                        url: 'https://google.com/books?vid=OCLC12345',
                                        hathitrust: false
                                      })
        end
      end

      context 'when the record access is not present' do
        it 'generates a url to google books' do
          document = { 'oclc_number_ssim': ['12345'],
                       'ht_access_ss': nil }
          hathi_link = SolrDocument.new(document).hathi_links

          expect(hathi_link).to match({
                                        text: I18n.t('blackcat.hathitrust.alt_hathi_text'),
                                        url: 'https://google.com/books?vid=OCLC12345',
                                        hathitrust: false
                                      })
        end
      end
    end
  end
end
