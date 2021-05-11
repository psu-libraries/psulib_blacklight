# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'external_links/access_online_links', type: :view do
  let(:access_online_fields) {
    [
      {
        prefix: 'This is a prefix',
        text: 'purl.access.gpo.gov',
        url: 'http://purl.access.gpo.gov/GPO/LPS73013',
        notes: 'This is a note'
      }.with_indifferent_access,
      {
        text: 'purl.access.gpo.gov',
        url: 'http://purl.access.gpo.gov/GPO/LPS73014'
      }.with_indifferent_access
    ]
  }

  it 'renders a list of links with correct display text and URLs' do
    render 'external_links/access_online_links', access_online_links: access_online_fields

    expect(rendered).to have_link(href: 'http://purl.access.gpo.gov/GPO/LPS73013')
      .and have_link(href: 'http://purl.access.gpo.gov/GPO/LPS73014')
      .and include('This is a prefix')
      .and include('This is a note')
  end
end
