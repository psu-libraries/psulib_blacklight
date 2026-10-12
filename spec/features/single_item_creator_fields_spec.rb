# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Single Item Creator Fields' do
  describe 'Additional Creators', :js do
    before do
      visit '/catalog/1193913'
    end

    it 'displays all creators as a sentence with facet links' do
      within '.blacklight-addl_author_display_ssm' do
        expect(page).to have_text(
          'Dugan, Raymond Smith, 1878-1940, Stewart, John Quincy, 1894-1972, and Young, Charles A. (Charles Augustus), 1834-1908'
        )
        expect(page).to have_link('Dugan, Raymond Smith, 1878-1940', href: /all_authors_facet/)
        expect(page).to have_link('Stewart, John Quincy, 1894-1972', href: /all_authors_facet/)
        expect(page).to have_link('Young, Charles A. (Charles Augustus), 1834-1908', href: /all_authors_facet/)
      end
    end
  end
end
