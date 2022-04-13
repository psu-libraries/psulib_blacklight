# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Call Number Browse', type: :feature do
  context 'when Browse by LC Call Numbers' do
    context 'when the user is not searching for a particular call number' do
      specify do
        visit '/browse/call_numbers?classification=lc'

        expect(page).to have_selector 'h2.h4',
                                      exact_text: 'AP3.M33 to BM516.B5134 1948'

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
          visit '/browse/call_numbers?nearby=F127.A2M9 1869&classification=lc'

          expect(page).to have_selector 'h2.h4',
                                        exact_text: 'E909.O24A3 2018 to HD4909.H5 1948'

          expect(page).to have_link('F127.A2M9 1869', href: '/catalog/213578')

          expect(page).to have_selector 'tr.table-primary:nth-child(2) td:nth-child(2)',
                                        exact_text: 'Adventures in the wilderness, or, Camp life in '\
                                                    'the Adirondacks / By William H.H. Murray ...'

          expect(page).to have_selector 'tr.table-primary:nth-child(2) td:nth-child(3)',
                                        exact_text: 'Annex / Special Collections Library'

          expect(page).to have_selector 'tr.table-primary:nth-child(2) td:nth-child(4)',
                                        exact_text: 'Boston : Fields, Osgood & co., 1869.'
        end
      end

      context 'when there is not an exact match' do
        specify do
          visit '/browse/call_numbers?nearby=LOL&classification=lc'

          expect(page).to have_selector 'h2.h4',
                                        exact_text: 'LC1421.M83 1801 v.1-2 to M1600.H133B45 1998 CD'

          expect(page).to have_selector 'tr.table-primary:nth-child(2) td',
                                        exact_text: 'You\'re looking for: LOL'
        end
      end
    end
  end

  context 'when Browse by DEWEY Call Numbers' do
    context 'when the user is not searching for a particular call number' do
      specify do
        visit '/browse/call_numbers?classification=dewey'

        expect(page).to have_selector 'h2.h4',
                                      exact_text: '001B289h to 660.6So1r'

        expect(page).not_to have_selector '.table-primary'

        expect(page).to have_link('001B289h', href: '/catalog/839980')
        expect(page).to have_selector 'tr:nth-child(2) td:nth-child(2)',
                                      exact_text: 'The beautiful / by Henry Rutgers Marshall'
        expect(page).to have_selector 'tr:nth-child(2) td:nth-child(3)',
                                      exact_text: 'Annex / Penn State Harrisburg'
        expect(page).to have_selector 'tr:nth-child(2) td:nth-child(4)',
                                      exact_text: 'London : Macmillan, 1924.'
      end
    end

    context 'when the user is searching for a particular call number' do
      context 'when there is an exact match' do
        specify do
          visit '/browse/call_numbers?nearby=301.154G854c&classification=dewey'

          expect(page).to have_selector 'h2.h4',
                                        exact_text: '294.516B14b Zs to 977.3Il6c v.11'

          expect(page).to have_link('301.154G854c', href: '/catalog/1373276')

          expect(page).to have_selector 'tr.table-primary:nth-child(2) td:nth-child(2)',
                                        exact_text: 'Children and politics / by Fred I. Greenstein'

          expect(page).to have_selector 'tr.table-primary:nth-child(2) td:nth-child(3)',
                                        exact_text: 'Annex / Penn State Behrend / Penn State Harrisburg'

          expect(page).to have_selector 'tr.table-primary:nth-child(2) td:nth-child(4)',
                                        exact_text: 'New Haven : Yale University Press, 1965.'
        end
      end

      context 'when there is not an exact match' do
        specify do
          visit '/browse/call_numbers?nearby=LOL&classification=dewey'

          expect(page).to have_selector 'h2.h4',
                                        exact_text: '977.3Il6c v.11 to None'

          expect(page).to have_selector 'tr.table-primary:nth-child(2) td',
                                        exact_text: 'You\'re looking for: LOL'
        end
      end
    end
  end
end
