# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Facet Queries', type: :feature do
  it 'All Authors Facet' do
    visit '/?f%5Ball_authors_facet%5D%5B%5D=Chanukoff%2C+L.%2C+1892-1958'
    expect(page).to have_selector '.filter-name',
                                  exact_text: 'All Authors Facet'
    expect(page).to have_selector '.filter-value',
                                  exact_text: 'Chanukoff, L., 1892-1958'
    expect(page).to have_selector 'article[data-document-id="3750004"]'
  end

  it 'Subject Facet' do
    visit '/?f[subject_facet][]=Islamic+decorative+arts%E2%80%94Turkey'
    expect(page).to have_selector '.filter-name',
                                  exact_text: 'Subject Facet'
    expect(page).to have_selector '.filter-value',
                                  exact_text: 'Islamic decorative arts—Turkey'
    expect(page).to have_selector 'article[data-document-id="21322677"]'
  end

  it 'Title Facet' do
    visit '/?f%5Btitle_sort%5D%5B%5D=Becoming'
    expect(page).to have_selector '.filter-name',
                                  exact_text: 'Title'
    expect(page).to have_selector '.filter-value',
                                  exact_text: 'Becoming'
    expect(page).to have_selector 'article[data-document-id="24053587"]'
  end
end
