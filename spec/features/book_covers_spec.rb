require 'rails_helper'

RSpec.feature "BookCovers", type: :feature do

  describe "User searches for a book" do
    before(:all) do
      jsonp_response = File.open('./spec/fixtures/google_books_api_jsonp.js')
      stub_request(:get, "https://books.google.com/books?jscmd=viewapi&bibkeys=ISBN:9780688061708,ISBN:0688061702,OCLC:19125179,LCCN:89000046&callback=jQuery34104256224926482822_1568383365808&_=1568383365809")
        .to_return(status: 200, body: jsonp_response)
    end

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
