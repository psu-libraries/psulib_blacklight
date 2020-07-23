# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HathiLinks do
  subject(:hathi_links) { SolrDocument.new(document).hathi_links }

  let(:document) { {} }

  context 'when there is no Hathi data' do
    it { expect(hathi_links).not_to be_present }
  end

  context 'when hathi etas is disabled' do
    before do
      Settings.hathi_etas = false
    end

    context 'with public domain hathi mono item' do
      let(:document) { { 'hathitrust_struct': ['{"ht_id":"12345","access":"allow"}'] } }

      it 'generates a url to the checkout page or scan view with the public domain text' do
        expect(hathi_links).to match({
                                       text: 'Access digital copy through HathiTrust',
                                       url: 'https://hdl.handle.net/2027/12345',
                                       additional_text: nil,
                                       etas_item: false
                                     })
      end
    end

    context 'with public domain hathi multi/serial item' do
      let(:document) { { 'hathitrust_struct': ['{"ht_bib_key":"12345","access":"allow"}'] } }

      it 'generates a url to the catalog record with the public domain text' do
        expect(hathi_links).to match({
                                       text: 'Access digital copy through HathiTrust',
                                       url: 'https://catalog.hathitrust.org/Record/12345',
                                       additional_text: nil,
                                       etas_item: false
                                     })
      end
    end

    context 'with restricted domain items' do
      let(:document) { { 'hathitrust_struct': ['{"ht_id":"12345","access":"deny"}'] } }

      it 'generates a url with the restricted items text' do
        expect(hathi_links).to match({
                                       text: I18n.t('blackcat.hathitrust.restricted_access_text'),
                                       url: 'https://hdl.handle.net/2027/12345',
                                       additional_text: nil,
                                       etas_item: false
                                     })
      end
    end
  end

  context 'when hathi etas is enabled' do
    before do
      Settings.hathi_etas = true
    end

    context 'with public domain items' do
      let(:document) { { 'hathitrust_struct': ['{"ht_id":"12345","access":"allow"}'] } }

      it 'generates a url with the public domain text' do
        expect(hathi_links).to match({
                                       text: I18n.t('blackcat.hathitrust.public_domain_text'),
                                       url: 'https://hdl.handle.net/2027/12345',
                                       additional_text: nil,
                                       etas_item: false
                                     })
      end
    end

    context 'with etas mono item' do
      let(:document) { { 'hathitrust_struct': ['{"ht_id":"12345","access":"deny"}'] } }

      it 'generates a url to the checkout page or scan view with the etas text' do
        expect(hathi_links).to match({
                                       text: I18n.t('blackcat.hathitrust.etas_text'),
                                       url: 'https://hdl.handle.net/2027/12345?urlappend=%3Bsignon=swle:urn:mace:incommon:psu.edu',
                                       additional_text: I18n.t('blackcat.hathitrust.etas_additional_text'),
                                       etas_item: true
                                     })
      end
    end

    context 'with etas multi/serial item' do
      let(:document) { { 'hathitrust_struct': ['{"ht_bib_key":"12345","access":"deny"}'] } }

      it 'generates a url to the catalog record with the etas text' do
        expect(hathi_links).to match({
                                       text: I18n.t('blackcat.hathitrust.etas_text'),
                                       url: 'https://catalog.hathitrust.org/Record/12345?urlappend=%3Bsignon=swle:urn:mace:incommon:psu.edu',
                                       additional_text: I18n.t('blackcat.hathitrust.etas_additional_text'),
                                       etas_item: true
                                     })
      end
    end
  end
end
