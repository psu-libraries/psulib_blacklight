# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HathiLinks do
  describe '#hathi_links' do
    it 'returns nil when there is no Hathi data' do
      document = { 'oclc_number_ssim': ['12345'] }
      hathi_link = SolrDocument.new(document).hathi_links

      expect(hathi_link).not_to be_present
    end

    context 'when hathi etas is disabled' do
      before do
        Settings.hathi_etas = false
      end

      it 'generates a url with the public domain text when the record access is "allow' do
        document = { 'oclc_number_ssim': ['12345'],
                     'ht_access_ss': 'allow' }
        hathi_link = SolrDocument.new(document).hathi_links

        expect(hathi_link).to match({
                                      text: I18n.t('blackcat.hathitrust.public_domain_text'),
                                      url: 'https://catalog.hathitrust.org/api/volumes/oclc/12345.html',
                                      additional_text: nil,
                                      etas_item: false
                                    })
      end

      it 'generates a url with the restricted items text when the record access is "deny"' do
        document = { 'oclc_number_ssim': ['12345'],
                     'ht_access_ss': 'deny' }
        hathi_link = SolrDocument.new(document).hathi_links

        expect(hathi_link).to match({
                                      text: I18n.t('blackcat.hathitrust.restricted_access_text'),
                                      url: 'https://catalog.hathitrust.org/api/volumes/oclc/12345.html',
                                      additional_text: nil,
                                      etas_item: false
                                    })
      end
    end

    context 'when hathi etas is enabled' do
      before do
        Settings.hathi_etas = true
      end

      it 'generates a url with the public domain text' do
        document = { 'oclc_number_ssim': ['12345'],
                     'ht_access_ss': 'allow' }
        hathi_link = SolrDocument.new(document).hathi_links

        expect(hathi_link).to match({
                                      text: I18n.t('blackcat.hathitrust.public_domain_text'),
                                      url: 'https://catalog.hathitrust.org/api/volumes/oclc/12345.html',
                                      additional_text: nil,
                                      etas_item: false
                                    })
      end

      it 'generates a url to the checkout page or scan view with the etas text' do
        document = { 'oclc_number_ssim': ['12345'],
                     'ht_access_ss': 'deny' }
        hathi_link = SolrDocument.new(document).hathi_links

        expect(hathi_link).to match({
                                      text: I18n.t('blackcat.hathitrust.etas_text'),
                                      url: 'https://catalog.hathitrust.org/api/volumes/oclc/12345.html?urlappend=%3Bsignon=swle:urn:mace:incommon:psu.edu',
                                      additional_text: I18n.t('blackcat.hathitrust.etas_additional_text'),
                                      etas_item: true
                                    })
      end
    end
  end
end
