# frozen_string_literal: true

require 'rails_helper'
require 'support/vcr'

RSpec.feature 'External Links', type: :feature do
  context 'when user searches for a record' do
    context 'when record has no external links' do
      it 'does not display any links' do
        visit 'catalog/26513585'
        expect(page).not_to have_selector '.external_links'
      end
    end

    context 'when record has less than 3 links of the same type' do
      before do
        visit 'catalog/3500414'
      end

      it 'does not displays a toggle button' do
        expect(page).not_to have_selector '.toggle-external-links' end

      it 'displays at least 2 links as preview' do
        expect(page).to have_link('purl.access.gpo.gov', href: 'http://purl.access.gpo.gov/GPO/LPS73013')
          .and have_link('purl.access.gpo.gov', href: 'http://purl.access.gpo.gov/GPO/LPS73014')
      end
    end

    context 'when record has more than 3 links of the same type', js: true do
      it 'displays a toggle button'
      it 'displays 2 links as preview'
      it 'toggles links correctly'
    end

    context 'when record has links of the different types', js: true do
      it 'toggles links correctly'
    end
  end

  context 'when user visits catalog record page' do
    context 'when record has less than 3 links of the same type' do
      it 'does not display any external links' do
        visit '?search_field=all_fields&q=40+short+stories'
        expect(page).not_to have_selector '.external_links'
      end
    end

    context 'when record has less than 3 links of the same type' do
      before do
        visit '?search_field=all_fields&q=+LARCHER+Pierre'
      end

      it 'does not displays a toggle button' do
        expect(page).not_to have_selector '.toggle-external-links' end

      it 'displays at least 2 links as preview' do
        expect(page).to have_link('journals.openedition.org',
                                  href: 'http://journals.openedition.org/remmm/10194')
      end
    end

    context 'when record has more than 3 links of the same type', js: true do
      it 'displays a toggle button'
      it 'displays 2 links as preview'
      it 'toggles links correctly'
    end

    context 'when record has links of the different types', js: true do
      it 'toggles links correctly'
    end
  end
end
