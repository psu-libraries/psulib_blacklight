# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::HathiLinkComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(document: document))
  end

  context 'when document has an OCLC, LCCN and ISSN' do
    let(:document) { { 'lccn_ssim' => ['13579'], 'oclc_number_ssim' => ['24680'], 'issn_ssm' => ['1234-1234'] } }

    it 'renders a hidden link with the OCLC search path and OCLC attached in the data attr' do
      expect(rendered).to have_css("img[src*='Springshare-LibGuide-Image-100X100-872acafb7418ee18a303.png']", visible: :hidden)
        .and have_css("div[data-search-item='oclc/24680']", visible: :hidden)
    end
  end

  context 'when document has an LCCN and ISSN' do
    let(:document) { { 'lccn_ssim' => ['13579'], 'issn_ssm' => ['1234-1234'] } }

    it 'renders a hidden link with the LCCN search path and LCCN attached in the data attr' do
      expect(rendered).to have_css("img[src*='Springshare-LibGuide-Image-100X100-872acafb7418ee18a303.png']", visible: :hidden)
        .and have_css("div[data-search-item='lccn/13579']", visible: :hidden)
    end
  end

  context 'when document has only an ISSN' do
    let(:document) { { 'issn_ssm' => ['1234-1234'] } }

    it 'renders a hidden link with the ISSN search path and ISSN attached in the data attr' do
      expect(rendered).to have_css("img[src*='Springshare-LibGuide-Image-100X100-872acafb7418ee18a303.png']", visible: :hidden)
        .and have_css("div[data-search-item='issn/1234-1234']", visible: :hidden)
    end
  end

  context 'when document has no OCLC, lCCN or ISSN' do
    let(:document) { {} }

    it 'renders a hidden link with no attached search term data' do
      expect(rendered).to have_css("img[src*='Springshare-LibGuide-Image-100X100-872acafb7418ee18a303.png']", visible: :hidden)
        .and have_css("div[data-search-item='']", visible: :hidden)
    end
  end

  context 'when document has an ISSN, but is Free to Read' do
    let(:document) { { 'access_facet' => ['Free to Read', 'In the Library'], 'issn_ssm' => ['1234-1234'] } }

    it 'renders a hidden link with no attached search term data' do
      expect(rendered).to have_css("img[src*='Springshare-LibGuide-Image-100X100-872acafb7418ee18a303.png']", visible: :hidden)
        .and have_css("div[data-search-item='']", visible: :hidden)
    end
  end
end
