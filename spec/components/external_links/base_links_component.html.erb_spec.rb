# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::BaseLinksComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(links: links, heading: heading))
  end

  let(:heading) { 'External Links' }
  let(:links) {
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

  it 'renders the heading correctly' do
    expect(rendered).to have_selector 'h5', text: 'External Links'
  end

  it 'renders a list of links with correct display text and URLs' do
    expect(rendered).to have_link('purl.access.gpo.gov', href: 'http://purl.access.gpo.gov/GPO/LPS73013')
      .and have_link('purl.access.gpo.gov', href: 'http://purl.access.gpo.gov/GPO/LPS73014')
      .and have_text('This is a prefix')
      .and have_text('This is a note')
  end
end
