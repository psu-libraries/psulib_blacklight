# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'external_links/psu_digital_collections_links', type: :view do
  let(:psu_digital_collections_fields) {
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
    render 'external_links/psu_digital_collections_links', psu_digital_collections_links: psu_digital_collections_fields

    expect(rendered).to have_link(href: 'https://digital.libraries.psu.edu/digital/collection/lavie/search')
      .and include('digital.libraries.psu.edu')
      .and include('This is a prefix')
      .and include('This is a note')
  end
end
