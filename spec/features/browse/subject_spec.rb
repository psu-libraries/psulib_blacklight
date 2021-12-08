# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Subject Browse', type: :feature do
  context 'when starting at the beginning' do
    specify do
      visit subject_browse_path

      expect(page).to have_selector('h1', text: 'Browse by Subject')

      within('thead') do
        expect(page).to have_content('Subject Heading')
        expect(page).to have_content('Count')
      end

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('Adirondack Mountains (N.Y.)', href: /subject_browse_facet/)
        expect(page).to have_selector('td', text: 1)
      end

      within('tbody tr:nth-child(20)') do
        expect(page).to have_link('Animals—Treatment—Fiction', href: /subject_browse_facet/)
        expect(page).to have_selector('td', text: 1)
      end

      first(:link, 'Next').click

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('Archaeology—History', href: /subject_browse_facet/)
        expect(page).to have_selector('td', text: 1)
      end

      within('tbody tr:nth-child(20)') do
        expect(page).to have_link('Bangladesh—Drama', href: /subject_browse_facet/)
        expect(page).to have_selector('td', text: 1)
      end
    end
  end

  context 'when starting on a specific page' do
    specify do
      visit subject_browse_path(page: '3')

      expect(page).to have_selector('h1', text: 'Browse by Subject')

      within('thead') do
        expect(page).to have_content('Subject Heading')
        expect(page).to have_content('Count')
      end

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('Banks and banking—Congresses', href: /subject_browse_facet/)
        expect(page).to have_selector('td', text: 1)
      end

      within('tbody tr:nth-child(20)') do
        expect(page).to have_link('Blind—Education—Pennsylvania—Periodicals', href: /subject_browse_facet/)
        expect(page).to have_selector('td', text: 1)
      end

      first(:link, 'Previous').click

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('Archaeology—History', href: /subject_browse_facet/)
        expect(page).to have_selector('td', text: 1)
      end

      within('tbody tr:nth-child(20)') do
        expect(page).to have_link('Bangladesh—Drama', href: /subject_browse_facet/)
        expect(page).to have_selector('td', text: 1)
      end
    end
  end

  context 'when viewing records with multiple facet headings' do
    specify do
      visit subject_browse_path(prefix: 'Q')

      expect(page).to have_selector('td', text: /^Quilting—Pennsylvania—Cumberland County—History—18th century$/)
      expect(page).to have_selector('td', text: /^Quilting—Pennsylvania—Cumberland County—History—19th century$/)
      expect(page).not_to have_selector('td', text: /^Quilting—Pennsylvania—Cumberland County—History$/)
      expect(page).not_to have_selector('td', text: /^Quilting—Pennsylvania—Cumberland County$/)
      expect(page).not_to have_selector('td', text: /^Quilting—Pennsylvania$/)
      expect(page).not_to have_selector('td', text: /^Quilting$/)
    end
  end
end
