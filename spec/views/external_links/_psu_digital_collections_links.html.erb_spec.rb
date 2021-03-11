# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'external_links/psu_digital_collections_links', type: :view do
  let(:psu_digital_collections_fields) {
    [
      {
        text: 'digital.libraries.psu.edu',
        url: 'https://digital.libraries.psu.edu/digital/collection/lavie/search'
      }.with_indifferent_access
    ]
  }

  it 'renders a list of links with correct display text and URLs' do
    render 'external_links/psu_digital_collections_links', psu_digital_collections_links: psu_digital_collections_fields

    expect(rendered).to have_link(href: 'https://digital.libraries.psu.edu/digital/collection/lavie/search')
      .and include('digital.libraries.psu.edu')
  end
end
