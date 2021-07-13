# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'external_links/all', type: :view do
  let(:document) { SolrDocument.new(
    {
      'oclc_number_ssim': ['12345'],
      'ht_access_ss': 'allow'
    }
  )}

  it 'renders Hathi links when present and show_hathi_links is true' do
    render 'external_links/all', document: document, show_hathi_links: true

    expect(rendered).to have_link(href: 'https://catalog.hathitrust.org/api/volumes/oclc/12345.html')
      .and have_css("img[src*='HathiTrust_logo']")
      .and include(I18n.t('blackcat.hathitrust.public_domain_text'))
  end

  it 'does not render Hathi links when show_hathi_links is false' do
    render 'external_links/all', document: document, show_hathi_links: false

    expect(rendered).not_to have_link(href: 'https://catalog.hathitrust.org/api/volumes/oclc/12345.html')
    expect(rendered).not_to have_css("img[src*='HathiTrust_logo']")
    expect(rendered).not_to include(I18n.t('blackcat.hathitrust.public_domain_text'))
  end
end
