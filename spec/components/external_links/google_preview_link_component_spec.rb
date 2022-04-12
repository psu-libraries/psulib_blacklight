# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::GooglePreviewLinkComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(document: document))
  end

  context 'when document has an LCCN, OCLC and ISBN' do
    let(:document) { { 'lccn_ssim' => ['13579'], 'oclc_number_ssim' => ['24680'], 'isbn_valid_ssm' => ['92746'] } }

    it 'renders a hidden link with the LCCN search term and LCCN attached in the data attr' do
      expect(rendered).to have_css("img[src*='gbs_preview_button1']", visible: :hidden)
        .and have_css("a[data='LCCN:13579']", visible: :hidden)
    end
  end

  context 'when document has an OCLC and ISBN' do
    let(:document) { { 'oclc_number_ssim' => ['24680'], 'isbn_valid_ssm' => ['92746'] } }

    it 'renders a hidden link with the OCLC search term and OCLC attached in the data attr' do
      expect(rendered).to have_css("img[src*='gbs_preview_button1']", visible: :hidden)
        .and have_css("a[data='OCLC:24680']", visible: :hidden)
    end
  end

  context 'when document has only an ISBN' do
    let(:document) { { 'isbn_valid_ssm' => ['92746'] } }

    it 'renders a hidden link with the ISBN search term and ISBN attached in the data attr' do
      expect(rendered).to have_css("img[src*='gbs_preview_button1']", visible: :hidden)
        .and have_css("a[data='ISBN:92746']", visible: :hidden)
    end
  end
end
