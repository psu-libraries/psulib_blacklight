# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'external_links/hathi_links', type: :view do
  let(:hathi_fields) {
    {
      text: I18n.t('blackcat.hathitrust.public_domain_text'),
      url: 'https://catalog.hathitrust.org/Record/12345',
      additional_text: I18n.t('blackcat.hathitrust.etas_additional_text')
    }
  }

  it 'renders a hathi logo linked to hathi record with correct text' do
    render 'external_links/hathi_links', hathi_links: hathi_fields

    expect(rendered).to have_link(href: 'https://catalog.hathitrust.org/Record/12345')
      .and have_css("img[src*='HathiTrust_logo']")
      .and include(I18n.t('blackcat.hathitrust.public_domain_text'))
      .and have_css('p.record-view-only', text: I18n.t('blackcat.hathitrust.etas_additional_text'))
  end
end
