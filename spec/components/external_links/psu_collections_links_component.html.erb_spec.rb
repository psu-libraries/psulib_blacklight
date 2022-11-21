# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::PsuCollectionsLinksComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(links: psu_collections_links))
  end

  context 'when given digital collections links' do
    let(:psu_collections_links) {
      [
        {
          prefix: 'This is a prefix',
          text: 'digital.libraries.psu.edu',
          url: 'https://digital.libraries.psu.edu/digital/collection/lavie/search',
          notes: 'This is a note'
        }.with_indifferent_access
      ]
    }

    it 'renders a list of links with correct display text and URLs' do
      expect(rendered).to have_link('digital.libraries.psu.edu', href: 'https://digital.libraries.psu.edu/digital/collection/lavie/search')
        .and have_text('This is a prefix')
        .and have_text('This is a note')
        .and have_text('View in Penn State Digital Collections')
        .and have_no_text('Special Collections Materials')
    end
  end

  context 'when given special collections links' do
    let(:psu_collections_links) {
      [
        {
          text: 'View Finding Aid',
          url: 'http://n2t.net/ark:/42409/fa812345'
        }.with_indifferent_access
      ]
    }

    it 'renders a list of links with correct display text and URLs' do
      expect(rendered).to have_link('View Finding Aid', href: 'http://n2t.net/ark:/42409/fa812345')
        .and have_text('Special Collections Materials')
        .and have_no_text('View in Penn State Digital Collections')
    end
  end
end
