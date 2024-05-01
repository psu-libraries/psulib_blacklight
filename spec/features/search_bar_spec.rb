# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search Bar' do
  describe 'selected search box field', :js do
    it 'shows normal placeholder info when doing a keyword search' do
      visit '/?search_field=all_fields&q='
      expect(page).to have_select('search_field', selected: 'Keyword')
      expect(page).to have_css('#q[placeholder="Search..."]')
    end

    it 'shows lc call number browse info when browsing by call number' do
      visit '/browse/call_numbers?nearby=LOL&classification=lc'
      expect(page).to have_select('search_field', selected: 'Browse by LC Call Number')
      expect(page).to have_css('#q[placeholder="e.g. NK 9112 .A28"]')
    end

    it 'shows dewey call number browse info when browsing by call number' do
      visit '/browse/call_numbers?nearby=LOL&classification=dewey'
      expect(page).to have_select('search_field', selected: 'Browse by Dewey Call Number')
      expect(page).to have_css('#q[placeholder="e.g. 332.094K634f"]')
    end

    it 'shows author browse info when browsing by author' do
      visit '/browse/authors?prefix=A'
      expect(page).to have_select('search_field', selected: 'Browse by Author')
      expect(page).to have_css('#q[placeholder="e.g. Hurston, Zora"]')
    end

    it 'shows subject browse info when browsing by subject' do
      visit '/browse/subjects?prefix=S'
      expect(page).to have_select('search_field', selected: 'Browse by Subject')
      expect(page).to have_css('#q[placeholder="e.g. Microbiology"]')
    end

    it 'shows title browse info when browsing by title' do
      visit '/browse/titles?prefix=T'
      expect(page).to have_select('search_field', selected: 'Browse by Title')
      expect(page).to have_css('#q[placeholder="Search..."]')
    end
  end

  it 'shows links for Advanced Search and Start Over', :js do
    visit '/'
    expect(page).to have_link('Advanced search', href: '/advanced')
    expect(page).to have_link('Start Over', href: '/')
  end

  it 'updates the placeholder when the search type changes', :js do
    visit '/'

    expect(page).to have_css('#q[placeholder="Search..."]')

    select 'Browse by LC Call Number', from: 'search_field'
    expect(page).to have_select('search_field', selected: 'Browse by LC Call Number')
    expect(page).to have_css('#q[placeholder="e.g. NK 9112 .A28"]')

    select 'Browse by Dewey Call Number', from: 'search_field'
    expect(page).to have_select('search_field', selected: 'Browse by Dewey Call Number')
    expect(page).to have_css('#q[placeholder="e.g. 332.094K634f"]')

    select 'Browse by Author', from: 'search_field'
    expect(page).to have_select('search_field', selected: 'Browse by Author')
    expect(page).to have_css('#q[placeholder="e.g. Hurston, Zora"]')

    select 'Browse by Subject', from: 'search_field'
    expect(page).to have_select('search_field', selected: 'Browse by Subject')
    expect(page).to have_css('#q[placeholder="e.g. Microbiology"]')

    select 'Browse by Title', from: 'search_field'
    expect(page).to have_select('search_field', selected: 'Browse by Title')
    expect(page).to have_css('#q[placeholder="Search..."]')
  end
end
