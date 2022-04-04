# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::HathiLinksComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(links: hathi_links))
  end

  context 'when hathi_links #hathitrust is true' do
    let(:hathi_links) {
      {
        text: I18n.t('blackcat.hathitrust.public_domain_text'),
        url: 'https://catalog.hathitrust.org/Record/12345',
        hathitrust: true
      }
    }

    it 'renders a hathi logo linked to hathi record with correct text' do
      expect(rendered).to have_link(href: 'https://catalog.hathitrust.org/Record/12345')
        .and have_css("img[src*='HathiTrust_logo']")
        .and have_text(I18n.t('blackcat.hathitrust.public_domain_text'))
    end
  end

  context 'when hathi_links #hathitrust is false' do
    let(:hathi_links) {
      {
        text: I18n.t('blackcat.hathitrust.alt_hathi_text'),
        url: 'https://google.com/books?vid=OCLC12345',
        hathitrust: false
      }
    }

    it 'renders a google books logo linked to google books record with correct text' do
      expect(rendered).to have_link(href: 'https://google.com/books?vid=OCLC12345')
      expect(rendered).to have_css("img[src*='google_books_logo']")
      expect(rendered).to have_text(I18n.t('blackcat.hathitrust.alt_hathi_text'))
    end
  end
end
