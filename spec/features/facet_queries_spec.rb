# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Facet Queries' do
  it 'All Authors Facet' do
    visit '/?f%5Ball_authors_facet%5D%5B%5D=Chanukoff%2C+L.%2C+1892-1958'
    expect(page).to have_css '.filter-name',
                             exact_text: 'All Authors Facet'
    expect(page).to have_css '.filter-value',
                             exact_text: 'Chanukoff, L., 1892-1958'
    expect(page).to have_css 'article[data-document-id="3750004"]'
  end

  it 'Subject Facet' do
    visit '/?f[subject_facet][]=Islamic+decorative+arts%E2%80%94Turkey'
    expect(page).to have_css '.filter-name',
                             exact_text: 'Subject Facet'
    expect(page).to have_css '.filter-value',
                             exact_text: 'Islamic decorative arts—Turkey'
    expect(page).to have_css 'article[data-document-id="21322677"]'
  end

  it 'Title Facet' do
    visit '/?f%5Btitle_sort%5D%5B%5D=Becoming'
    expect(page).to have_css '.filter-name',
                             exact_text: 'Title'
    expect(page).to have_css '.filter-value',
                             exact_text: 'Becoming'
    expect(page).to have_css 'article[data-document-id="24053587"]'
  end

  context 'when search volume exceeds limit' do
    context 'when user is not logged in' do
      before do
        visit '/?f[access_facet][]=In+the+Library&f[campus_facet][]=University+Park&f[format][]=Book' \
              '&f[up_library_facet][]=Pattee+Library+and+Paterno+Library+Stacks'
      end

      it 'redirects to query limit page' do
        expect(page).to have_current_path('/query_limit')
      end

      context 'when the user is able to login' do
        before do
          user = User.create!(email: 'user1234@psu.edu')
          login_as(user, scope: :user)
          click_link 'log in'
        end

        it 'resumes the search' do
          expect(page).to have_current_path('/?f%5Baccess_facet%5D%5B%5D=In+the+Library&f%5B' \
                                            'campus_facet%5D%5B%5D=University+Park&f%5Bformat%5D%5B%5D' \
                                            '=Book&f%5Bup_library_facet%5D%5B%5D=Pattee+Library+and+' \
                                            'Paterno+Library+Stacks')
          expect(page).to have_css 'article[data-document-id="24053587"]'
        end
      end
    end

    context 'when user is logged in' do
      before do
        user = User.create!(email: 'user1234@psu.edu')
        login_as(user, scope: :user)
      end

      it 'displays search results' do
        visit '/?f[access_facet][]=In+the+Library&f[campus_facet][]=University+Park&f[format][]=Book' \
              '&f[up_library_facet][]=Pattee+Library+and+Paterno+Library+Stacks'
        expect(page).to have_css 'article[data-document-id="24053587"]'
      end
    end
  end
end
