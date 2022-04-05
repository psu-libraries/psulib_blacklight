# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::HathiLinksComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(links: hathi_links))
  end

  context 'when hathi_links is open_ht_access but not an etas_item' do
    let(:hathi_links) {
      {
        text: I18n.t('blackcat.hathitrust.public_domain_text'),
        url: 'https://catalog.hathitrust.org/Record/12345',
        additional_text: nil,
        etas_item: false,
        open_ht_access: true
      }
    }

    it 'renders a hathi logo linked to hathi record with correct text' do
      expect(rendered).to have_link(href: 'https://catalog.hathitrust.org/Record/12345')
        .and have_css("img[src*='HathiTrust_logo']")
        .and have_text(I18n.t('blackcat.hathitrust.public_domain_text'))
      expect(rendered).not_to have_content(I18n.t('blackcat.hathitrust.etas_additional_text'))
    end
  end

  context 'when hathi_links is open_ht_access and an etas_item' do
    let(:hathi_links) {
      {
        text: I18n.t('blackcat.hathitrust.etas_text'),
        url: 'https://catalog.hathitrust.org/Record/12345',
        additional_text: I18n.t('blackcat.hathitrust.etas_additional_text'),
        etas_item: true,
        open_ht_access: true
      }
    }

    it 'renders a hathi logo linked to hathi record with correct text' do
      expect(rendered).to have_link(href: 'https://catalog.hathitrust.org/Record/12345')
        .and have_css("img[src*='HathiTrust_logo']")
        .and have_text(I18n.t('blackcat.hathitrust.etas_text'))
      expect(rendered).to have_content(I18n.t('blackcat.hathitrust.etas_additional_text'))
      expect(rendered).to have_content('Full Text available online')
    end
  end

  context 'when hathi_links is neither open_ht_access nor an etas_item' do
    let(:hathi_links) {
      {
        text: I18n.t('blackcat.hathitrust.restricted_access_text'),
        url: 'https://google.com/books?vid=OCLC12345',
        additional_text: nil,
        etas_item: false,
        open_ht_access: false
      }
    }

    it 'renders a google books logo linked to google books record with correct text' do
      expect(rendered).to have_link(href: 'https://google.com/books?vid=OCLC12345')
      expect(rendered).to have_css("img[src*='google_books_logo']")
      expect(rendered).to have_text(I18n.t('blackcat.hathitrust.restricted_access_text'))
    end
  end

  context 'when hathi_links is nil' do
    let(:hathi_links) { nil }

    it 'renders nothing' do
      expect(rendered.to_s).to eq ''
    end
  end
end
