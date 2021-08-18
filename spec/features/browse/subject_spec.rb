# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Subject Browse', type: :feature do
  context 'when starting at the beginning' do
    specify do
      visit browse_subjects_path

      expect(page).to have_selector('h1', text: 'Browse by Subject')

      within('thead') do
        expect(page).to have_content('Subject Heading')
        expect(page).to have_content('Count')
      end

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('1600-1868')
        expect(page).to have_selector('td', text: 1)
      end

      within('tbody tr:nth-child(10)') do
        expect(page).to have_link('1939-1945')
        expect(page).to have_selector('td', text: 9)
      end

      first(:link, 'Next').click

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('1939-1951')
        expect(page).to have_selector('td', text: 1)
      end

      within('tbody tr:nth-child(10)') do
        expect(page).to have_link('Actualización de sí mismo (Psicología)—Teatro')
        expect(page).to have_selector('td', text: 1)
      end
    end
  end

  context 'when starting on a specific page' do
    specify do
      visit browse_subjects_path(page: '3')

      expect(page).to have_selector('h1', text: 'Browse by Subject')

      within('thead') do
        expect(page).to have_content('Subject Heading')
        expect(page).to have_content('Count')
      end

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('Adirondack Mountains (N.Y.)')
        expect(page).to have_selector('td', text: 1)
      end

      within('tbody tr:nth-child(10)') do
        expect(page).to have_link('Africa')
        expect(page).to have_selector('td', text: 1)
      end

      first(:link, 'Previous').click

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('1939-1951')
        expect(page).to have_selector('td', text: 1)
      end

      within('tbody tr:nth-child(10)') do
        expect(page).to have_link('Actualización de sí mismo (Psicología)—Teatro')
        expect(page).to have_selector('td', text: 1)
      end
    end
  end
end
