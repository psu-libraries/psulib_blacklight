# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::PsuDigitalCollectionsLinksComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(links: psu_digital_collections_links))
  end

  let(:psu_digital_collections_links) {
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
  end
end
