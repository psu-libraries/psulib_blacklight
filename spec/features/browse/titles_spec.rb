# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Title Browse', type: :feature do
  context 'when the user is not searching for a particular title' do
    specify do
      visit '/browse/titles?prefix='

      expect(page).to have_selector('h1', text: 'Browse by Title')

      within('thead') do
        expect(page).to have_content('Title')
        expect(page).to have_content('Count')
      end

      expect(page).to have_selector 'tr:nth-child(3) td:nth-child(1)',
                                    exact_text: '1960s film posters collection'

      first(:link, 'Next').click

      expect(page).to have_selector 'tr:nth-child(2) td:nth-child(1)',
                                    exact_text: 'American marriage'
    end
  end

  context 'when the user is searching for a specific title' do
    context 'when there is not a match' do
      specify do
        visit '/browse/titles?prefix=kinesiology'

        expect(page).to have_content 'No records found'
      end
    end

    context 'when there is at least one match' do
      specify do
        visit '/browse/titles?prefix=Becoming'

        expect(page).to have_selector 'tr:nth-child(1) td:nth-child(1)',
                                      exact_text: 'Becoming'
        expect(page).to have_selector 'tr:nth-child(2) td:nth-child(1)',
                                      exact_text: 'Becoming a champion the complete guide to the full swing'
      end
    end

    context 'when the user selects a specific title' do
      specify do
        visit '/browse/titles?prefix=Becoming'
        click_link 'Becoming'

        expect(page).to have_selector 'article[data-document-id="24053587"]'
        expect(page).not_to have_selector 'article[data-document-id="3626147"]'
      end
    end
  end
end
