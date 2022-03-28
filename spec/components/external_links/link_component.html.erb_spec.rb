# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::LinkComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(item))
  end

  let(:item) {
    {
      prefix: 'This is a prefix',
      text: 'purl.access.gpo.gov',
      url: 'http://purl.access.gpo.gov/GPO/LPS73013',
      notes: 'This is a note'
    }.with_indifferent_access
  }

  it 'renders a link with a prefix, text and notes' do
    expect(rendered).to have_link('purl.access.gpo.gov', href: 'http://purl.access.gpo.gov/GPO/LPS73013')
      .and have_text('This is a prefix')
      .and have_text('This is a note')
  end
end
