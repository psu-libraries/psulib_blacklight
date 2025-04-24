# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Subject Browse' do
  context 'when starting at the beginning' do
    specify do
      visit subject_browse_path

      expect(page).to have_css('h1', text: 'Browse by Subject')

      within('thead') do
        expect(page).to have_content('Subject Heading')
        expect(page).to have_content('Count')
      end

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('Adirondack Mountains (N.Y.)', href: /subject_browse_facet/)
        expect(page).to have_css('td', text: 1)
      end

      within('tbody tr:nth-child(20)') do
        expect(page).to have_link('Animals—Treatment—Fiction', href: /subject_browse_facet/)
        expect(page).to have_css('td', text: 1)
      end

      first(:link, 'Next').click

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('Aptheker, Herbert, 1915-2003', href: /subject_browse_facet/)
        expect(page).to have_css('td', text: 1)
      end

      within('tbody tr:nth-child(20)') do
        expect(page).to have_link('Authors, Yiddish—Soviet Union', href: /subject_browse_facet/)
        expect(page).to have_css('td', text: 1)
      end
    end
  end

  context 'when starting on a specific page' do
    specify do
      visit subject_browse_path(page: '3')

      expect(page).to have_css('h1', text: 'Browse by Subject')

      within('thead') do
        expect(page).to have_content('Subject Heading')
        expect(page).to have_content('Count')
      end

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('Authors—Drama', href: /subject_browse_facet/)
        expect(page).to have_css('td', text: 1)
      end

      within('tbody tr:nth-child(20)') do
        expect(page).to have_link('Biometry', href: /subject_browse_facet/)
        expect(page).to have_css('td', text: 1)
      end

      first(:link, 'Previous').click

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('Aptheker, Herbert, 1915-2003', href: /subject_browse_facet/)
        expect(page).to have_css('td', text: 1)
      end

      within('tbody tr:nth-child(20)') do
        expect(page).to have_link('Authors, Yiddish—Soviet Union', href: /subject_browse_facet/)
        expect(page).to have_css('td', text: 1)
      end
    end
  end

  context 'when viewing records with multiple facet headings' do
    specify do
      visit subject_browse_path(prefix: 'Q')

      expect(page).to have_css('td', text: /^Quilting—Pennsylvania—Cumberland County—History—18th century$/)
      expect(page).to have_css('td', text: /^Quilting—Pennsylvania—Cumberland County—History—19th century$/)
      expect(page).to have_no_css('td', text: /^Quilting—Pennsylvania—Cumberland County—History$/)
      expect(page).to have_no_css('td', text: /^Quilting—Pennsylvania—Cumberland County$/)
      expect(page).to have_no_css('td', text: /^Quilting—Pennsylvania$/)
      expect(page).to have_no_css('td', text: /^Quilting$/)
    end
  end

  context 'when the search prefix is lowercased' do
    specify do
      visit subject_browse_path(prefix: 'african american')

      expect(page).to have_link('African American women lawyers—Illinois—Chicago—Biography',
                                href: /subject_browse_facet/)
      expect(page).to have_link('African Americans—Civil rights', href: /subject_browse_facet/)
    end
  end
end
