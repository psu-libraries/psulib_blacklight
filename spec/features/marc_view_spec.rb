# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MARC view' do
  describe 'MARC view', :js do
    before do
      visit '/catalog/24053587'
    end

    it 'single item page contains link to MARC record' do
      expect(page).to have_css 'a[id="marc_record_link"]'
      expect(page).to have_link('View MARC record', href: '/catalog/24053587/marc_view')
    end

    context 'when MARC link is clicked' do
      before do
        sleep 0.5
        click_on 'View MARC record'
      end

      it 'displays MARC record' do
        expect(page).to have_content 'MARC View'
        expect(page).to have_content '003 SIRSI'
        expect(page).to have_content 'a| African American women lawyers z| Illinois z| Chicago v| Biography.'
      end
    end
  end
end
