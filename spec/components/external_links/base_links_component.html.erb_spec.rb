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
    expect(rendered).to have_css 'h5', text: 'External Links'
  end

  context 'when are less than 3 links of the same type' do
    it 'renders a list of links with correct display text and URLs' do
      expect(rendered).to have_link('purl.access.gpo.gov', href: 'http://purl.access.gpo.gov/GPO/LPS73013')
        .and have_link('purl.access.gpo.gov', href: 'http://purl.access.gpo.gov/GPO/LPS73014')
        .and have_text('This is a prefix')
        .and have_text('This is a note')
    end

    it 'does not display a view more button' do
      expect(rendered).to have_no_css '.toggle-external-links'
    end

    it 'does not collapse any links' do
      expect(rendered).to have_no_css('#collapseLinksExternalLinks')
    end
  end

  context 'when there are more than 3 links of the same type' do
    let(:links) {
      [
        {
          text: '1st link',
          url: 'url.1'
        }.with_indifferent_access,
        {
          text: '2nd link',
          url: 'url.2'
        }.with_indifferent_access,
        {
          text: '3rd link',
          url: 'url.3'
        }.with_indifferent_access,
        {
          text: '4th link',
          url: 'url.4'
        }.with_indifferent_access
      ]
    }

    it 'displays a view more button' do
      expect(rendered).to have_css '.toggle-external-links.collapsed'
    end

    it 'displays 2 links and collapses the rest' do
      expect(rendered).to have_link('1st link', href: 'url.1')
        .and have_link('2nd link', href: 'url.2')
      within('#collapseLinksExternalLinks') do
        expect(rendered).to have_link('3rd link', href: 'url.3')
        expect(rendered).to have_link('4th link', href: 'url.4')
      end
    end
  end

  context 'when there are exactly 3 links of the same type' do
    let(:links) {
      [
        {
          text: '1st link',
          url: 'url.1'
        }.with_indifferent_access,
        {
          text: '2nd link',
          url: 'url.2'
        }.with_indifferent_access,
        {
          text: '3rd link',
          url: 'url.3'
        }.with_indifferent_access
      ]
    }

    it 'displays 3 links' do
      expect(rendered).to have_link('1st link', href: 'url.1')
        .and have_link('2nd link', href: 'url.2')
        .and have_link('3rd link', href: 'url.3')
    end

    it 'does not display a view more button' do
      expect(rendered).to have_no_css '.toggle-external-links'
    end

    it 'does not collapse any links' do
      expect(rendered).to have_no_css('#collapseLinksExternalLinks')
    end
  end
end
