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
        expect(page).to have_link('Acetaldehyde—Germany')
        expect(page).to have_selector('td', text: 1)
      end

      within('tbody tr:nth-child(10)') do
        expect(page).to have_link('African Americans—Southern States')
        expect(page).to have_selector('td', text: 1)
      end

      first(:link, 'Next').click

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('Aggada')
        expect(page).to have_selector('td', text: 1)
      end

      within('tbody tr:nth-child(10)') do
        expect(page).to have_link('Analog-to-digital converters—Standards')
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
        expect(page).to have_link('Analog-to-digital converters—Testing—Standards')
        expect(page).to have_selector('td', text: 1)
      end

      within('tbody tr:nth-child(10)') do
        expect(page).to have_link('Australian literature—Periodicals')
        expect(page).to have_selector('td', text: 1)
      end

      first(:link, 'Previous').click

      within('tbody tr:nth-child(1)') do
        expect(page).to have_link('Aggada')
        expect(page).to have_selector('td', text: 1)
      end

      within('tbody tr:nth-child(10)') do
        expect(page).to have_link('Analog-to-digital converters—Standards')
        expect(page).to have_selector('td', text: 1)
      end
    end
  end
end
