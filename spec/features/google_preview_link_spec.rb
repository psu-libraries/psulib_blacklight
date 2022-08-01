# frozen_string_literal: true

require 'rails_helper'
require 'support/vcr'

RSpec.describe 'Google Preview Link', :vcr, type: :feature, js: true do
  before do
    allow_any_instance_of(ExternalLinks::GooglePreviewLinkComponent).to receive(:search_item).and_return 'LCCN:12345'
  end

  context 'when book is not in Google Books' do
    it 'does not display preview link' do
      visit 'catalog/3500414'
      expect(page).to have_css("img[src*='gbs_preview_button1']", visible: :hidden)
        .and have_css("div[data-search-item='LCCN:12345']", visible: :hidden)
    end
  end

  context 'when a preview exists in Google Books' do
    it 'does display preview link with preview message' do
      visit 'catalog/3500414'
      expect(page).to have_css("img[src*='gbs_preview_button1']", visible: :visible)
        .and have_css("div[id='google-preview']", visible: :visible)
        .and have_css("a[href*='https://books.google.com/books?id=iDuSDwAAQBAJ']",
                      visible: :visible)
        .and have_content('Search inside at Google Books')
    end
  end

  context 'when the full text exists in Google Books' do
    it 'does display preview link with full view message' do
      visit 'catalog/3500414'
      expect(page).to have_css("img[src*='gbs_preview_button1']", visible: :visible)
        .and have_css("div[id='google-preview']", visible: :visible)
        .and have_css("a[href*='https://books.google.com/books?id=iDuSDwAAQBAJ']",
                      visible: :visible)
        .and have_content('Read online at Google Books')
    end
  end

  context 'when book is in Google Books but no preview exists' do
    it 'does not display preview link' do
      visit 'catalog/3500414'
      expect(page).to have_css("img[src*='gbs_preview_button1']", visible: :hidden)
        .and have_css("div[data-search-item='LCCN:12345']", visible: :hidden)
    end
  end

  context "when returned result contains a link to a book in Google Books but the search item doesn't match" do
    it 'displays preview link for the returned result' do
      visit 'catalog/3500414'
      expect(page).to have_css("img[src*='gbs_preview_button1']", visible: :visible)
        .and have_css("div[id='google-preview']", visible: :visible)
        .and have_css("a[href*='https://books.google.com/books?id=iDuSDwAAQBAJ']",
                      visible: :visible)
        .and have_content('Search inside at Google Books')
    end
  end
end
