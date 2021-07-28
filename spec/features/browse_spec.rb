# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Browse', type: :feature do
  context 'when the user is not searching for a particular call number' do
    specify do
      visit '/browse'

      expect(page).to have_selector 'h2.h4',
                                    exact_text: 'AN502.L66M63 to AP50.U5 1981-82'

      expect(page).not_to have_selector '.table-primary'

      expect(page).to have_link('AP2.O354', href: '/catalog/107')
      expect(page).to have_selector 'tr:nth-child(4) td:nth-child(2)',
                                    exact_text: 'The Christmas locket'
      expect(page).to have_selector 'tr:nth-child(4) td:nth-child(3)',
                                    exact_text: 'Special Collections Library'
      expect(page).to have_selector 'tr:nth-child(4) td:nth-child(4)',
                                    exact_text: 'Boston : Roberts brothers, 1870-'
    end
  end

  context 'when the user is searching for a particular call number' do
    context 'when there is an exact match' do
      specify do
        visit '/browse?nearby=F592.4 1983'

        expect(page).to have_selector 'h2.h4',
                                      exact_text: 'F158.9.J5P3 1959 to G7273.T5 1968.S6'

        expect(page).to have_link('F592.4 1983', href: '/catalog/492891')

        expect(page).to have_selector 'tr.table-primary:nth-child(2) td:nth-child(2)',
                                      exact_text: 'The journals of the Lewis and Clark Expedition '\
                                                  '/ Gary E. Moulton, editor'

        expect(page).to have_selector 'tr.table-primary:nth-child(2) td:nth-child(3)',
                                      exact_text: 'Multiple Locations'

        expect(page).to have_selector 'tr.table-primary:nth-child(2) td:nth-child(4)',
                                      exact_text: 'Lincoln : University of Nebraska Press, ©1983-©2001.'
      end
    end

    context 'when there is not an exact match' do
      specify do
        visit '/browse?nearby=LOL'

        expect(page).to have_selector 'h2.h4',
                                      exact_text: 'LC1421.M83 1801 v.1-2 to M450.Y56A6 2013 CD'

        expect(page).to have_selector 'tr.table-primary:nth-child(2) td',
                                      exact_text: 'None'
      end
    end
  end
end
