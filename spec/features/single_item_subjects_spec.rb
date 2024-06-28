# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Single Item Subjects' do
  describe 'Single item subject links', :js do
    before do
      visit '/catalog/1839879'
    end

    it 'displays the subjects for a given item' do
      expect(page).to have_content 'African Americans—Civil rights'
      expect(page).to have_content 'Black Muslims'
      expect(page).to have_content 'United States—Race relations'
    end

    context 'when users want to search for the first term of a given subject' do
      before do
        click_on 'African Americans'
      end

      it 'takes them to a search result of the first term of a given subject' do
        expect(page).to have_css 'article[data-document-id="22080733"]'
        expect(page).to have_css 'article[data-document-id="1839879"]'
      end
    end

    context 'when users want to search for the full term of a given subject' do
      before do
        click_on 'African Americans—Civil rights'
      end

      it 'takes them to a search result of the full term of a given subject' do
        expect(page).to have_css 'article[data-document-id="1839879"]'
        expect(page).to have_no_css 'article[data-document-id="22080733"]'
      end
    end
  end
end
