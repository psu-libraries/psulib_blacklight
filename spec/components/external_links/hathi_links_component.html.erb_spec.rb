# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::HathiLinksComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(links: hathi_links, show_links: show_hathi_links))
  end

  context 'when show_hathi_links is true' do
    let(:show_hathi_links) { true }

    context 'when hathi_links is open_ht_access but not an etas_item' do
      let(:hathi_links) {
        {
          text: I18n.t!('blackcat.hathitrust.public_domain_text'),
          url: 'https://catalog.hathitrust.org/Record/12345',
          additional_text: nil,
          etas_item: false,
          open_ht_access: true
        }
      }

      it 'renders a hathi logo linked to hathi record with correct text' do
        expect(rendered).to have_link(href: 'https://catalog.hathitrust.org/Record/12345')
          .and have_css("img[src*='HathiTrust_logo']")
          .and have_text(I18n.t!('blackcat.hathitrust.public_domain_text'))
        expect(rendered).to have_no_content(I18n.t!('blackcat.hathitrust.etas_additional_text'))
      end
    end

    context 'when hathi_links is open_ht_access and an etas_item' do
      let(:hathi_links) {
        {
          text: I18n.t!('blackcat.hathitrust.etas_text'),
          url: 'https://catalog.hathitrust.org/Record/12345',
          additional_text: I18n.t!('blackcat.hathitrust.etas_additional_text'),
          etas_item: true,
          open_ht_access: true
        }
      }

      it 'renders a hathi logo linked to hathi record with correct text' do
        expect(rendered).to have_link(href: 'https://catalog.hathitrust.org/Record/12345')
          .and have_css("img[src*='HathiTrust_logo']")
          .and have_text(I18n.t!('blackcat.hathitrust.etas_text'))
        expect(rendered).to have_content(I18n.t!('blackcat.hathitrust.etas_additional_text'))
        expect(rendered).to have_content('Full Text available online')
      end
    end

    context 'when hathi_links is neither open_ht_access nor an etas_item' do
      let(:hathi_links) {
        {
          text: nil,
          url: 'https://catalog.hathitrust.org/Record/12345',
          additional_text: nil,
          etas_item: false,
          open_ht_access: false
        }
      }

      it 'renders nothing' do
        expect(rendered.to_s).to eq ''
      end
    end

    context 'when hathi_links is nil' do
      let(:hathi_links) { nil }

      it 'renders nothing' do
        expect(rendered.to_s).to eq ''
      end
    end
  end

  context 'when Hathi links present and show_hathi_links is false' do
    let(:show_hathi_links) { false }
    let(:hathi_links) {
      {
        text: I18n.t!('blackcat.hathitrust.public_domain_text'),
        url: 'https://catalog.hathitrust.org/Record/12345',
        additional_text: nil,
        etas_item: false,
        open_ht_access: true
      }
    }

    it 'renders nothing' do
      expect(rendered.to_s).to eq ''
    end
  end
end
