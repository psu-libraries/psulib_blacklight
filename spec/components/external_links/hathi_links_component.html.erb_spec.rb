# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::HathiLinksComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(links: hathi_links,
                                      show_links: show_hathi_links))
  end

  let(:hathi_links) {
    {
      text: I18n.t('blackcat.hathitrust.public_domain_text'),
      url: 'https://catalog.hathitrust.org/Record/12345',
      additional_text: I18n.t('blackcat.hathitrust.etas_additional_text')
    }
  }

  context 'when Hathi links present and show_hathi_links is true' do
    let(:show_hathi_links) { true }

    it 'renders a hathi logo linked to hathi record with correct text' do
      expect(rendered).to have_link(href: 'https://catalog.hathitrust.org/Record/12345')
        .and have_css("img[src*='HathiTrust_logo']")
        .and have_text(I18n.t('blackcat.hathitrust.public_domain_text'))
        .and have_css('p.record-view-only', text: I18n.t('blackcat.hathitrust.etas_additional_text'))
    end
  end

  context 'when Hathi links present and show_hathi_links is false' do
    let(:show_hathi_links) { false }

    it 'does not render hathi links' do
      expect(rendered).not_to have_link(href: 'https://catalog.hathitrust.org/Record/12345')
      expect(rendered).not_to have_css("img[src*='HathiTrust_logo']")
      expect(rendered).not_to have_text(I18n.t('blackcat.hathitrust.public_domain_text'))
      expect(rendered).not_to have_css('p.record-view-only', text: I18n.t('blackcat.hathitrust.etas_additional_text'))
    end
  end
end
