# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Facet Queries', type: :feature do
  it 'All Authors Facet' do
    visit '/?f%5Ball_authors_facet%5D%5B%5D=Chanukoff%2C+L.%2C+1892-1958'
    expect(page).to have_selector '.filter-name',
                                  exact_text: 'All Authors Facet'
    expect(page).to have_selector '.filter-value',
                                  exact_text: 'Chanukoff, L., 1892-1958'
    expect(page).to have_selector 'article[data-document-id="3750004"]'
  end

  it 'Subject Facet' do
    visit '/?f[subject_facet][]=Federal+aid+to+housing%E2%80%94United+States'
    expect(page).to have_selector '.filter-name',
                                  exact_text: 'Subject Facet'
    expect(page).to have_selector '.filter-value',
                                  exact_text: 'Federal aid to housing—United States'
    expect(page).to have_selector 'article[data-document-id="3500414"]'
  end
end
