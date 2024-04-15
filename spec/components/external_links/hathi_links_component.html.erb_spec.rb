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
