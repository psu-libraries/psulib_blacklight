require 'rails_helper'

RSpec.feature "BookCovers", type: :feature do

  describe "User searches for a book" do
    it "a book that happens to have a book cover in the Google Books API", js: true do
      visit "/?utf8=✓&search_field=all_fields&q=The+good+times+AND+0688061702"

      expect(page).to have_css('img[src="https://books.google.com/books/content?id=a0ZaAAAAMAAJ&printsec=frontcover&img=1&zoom=1"]')
    end
  end

  describe "User opens a catalog record page" do
    it "that happens to have a book cover in the Google Books API", js: true do
      visit "/catalog/435524"

      expect(page).to have_css('img[src="https://books.google.com/books/content?id=a0ZaAAAAMAAJ&printsec=frontcover&img=1&zoom=1"]')
    end
  end

end
