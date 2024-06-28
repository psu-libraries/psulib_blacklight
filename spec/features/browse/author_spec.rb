# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Author Browse' do
  context 'when starting at the beginning' do
    specify do
      visit author_browse_path

      expect(page).to have_css('h1', text: 'Browse by Author')

      within('thead') do
        expect(page).to have_content('Author')
        expect(page).to have_content('Count')
      end

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('01 Distribution', href: /all_authors_facet/)
        expect(page).to have_css('td', text: 1)
      end

      within('tbody tr:nth-child(20)') do
        expect(page).to have_link('Akhtar, Adeel', href: /all_authors_facet/)
        expect(page).to have_css('td', text: 1)
      end

      first(:link, 'Next').click

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('Akin, Fatih, 1973-', href: /all_authors_facet/)
        expect(page).to have_css('td', text: 1)
      end

      within('tbody tr:nth-child(20)') do
        expect(page).to have_link('American Occupational Therapy Association', href: /all_authors_facet/)
        expect(page).to have_css('td', text: 1)
      end
    end
  end

  context 'when starting on a specific page' do
    specify do
      visit author_browse_path(page: '3')

      expect(page).to have_css('h1', text: 'Browse by Author')

      within('thead') do
        expect(page).to have_content('Author')
        expect(page).to have_content('Count')
      end

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('American Occupational Therapy Foundation', href: /all_authors_facet/)
        expect(page).to have_css('td', text: 1)
      end

      within('tbody tr:nth-child(20)') do
        expect(page).to have_link('Arthur, James R.', href: /all_authors_facet/)
        expect(page).to have_css('td', text: 1)
      end

      first(:link, 'Previous').click

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('Akin, Fatih, 1973-', href: /all_authors_facet/)
        expect(page).to have_css('td', text: 1)
      end

      within('tbody tr:nth-child(20)') do
        expect(page).to have_link('American Occupational Therapy Association', href: /all_authors_facet/)
        expect(page).to have_css('td', text: 1)
      end
    end
  end

  context 'when the search prefix is lowercased' do
    specify do
      visit author_browse_path(prefix: 'glo')

      expect(page).to have_link('Global Film Initiative', href: /all_authors_facet/)
      expect(page).to have_no_link('Steinem, Gloria', href: /all_authors_facet/)
    end
  end
end
