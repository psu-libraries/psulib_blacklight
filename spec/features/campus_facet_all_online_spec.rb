# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Campus Facet Add All Online', type: :feature do
  describe 'Adding and removing online items to campus facet filter', js: true do
    it 'adds online items' do
      # This test is dependent on there being 24 Behrend items and 134
      # Online items. Adding records to the fixtures could break this.
      visit '/?f[campus_facet][]=Penn+State+Behrend'
      expect(page).to have_content ' 1 - 10 of 24 '
      click_on 'Include all online results'
      expect(page).to have_content ' 1 - 10 of 162 '
      click_on 'Remove online results'
      expect(page).to have_content ' 1 - 10 of 24 '
    end
  end
end
