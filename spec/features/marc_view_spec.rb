# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MARC view', type: :feature do
  describe 'MARC view', js: true do
    before do
      visit '/catalog/24053587'
    end

    it 'single item page contains link to MARC record' do
      expect(page).to have_selector 'a[id="marc_record_link"]'
      expect(page).to have_selector 'a[href="/catalog/24053587/marc_view"]'
    end

    context 'when MARC link is clicked' do
      it 'displays MARC record' do
        click_on 'View MARC record'
        expect(page).to have_content 'MARC View'
        expect(page).to have_content '003 SIRSI'
        expect(page).to have_content 'a| African American women lawyers z| Illinois z| Chicago v| Biography.'
      end
    end
  end
end
