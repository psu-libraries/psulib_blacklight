# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::HathiLinksComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(links: hathi_links))
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
