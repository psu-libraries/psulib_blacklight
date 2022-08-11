# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Header Navbar', type: :feature do
  it 'displays search bar except on Advanced Search' do
    visit root_path
    expect(page).to have_selector '.navbar-search'
  end

  it 'does not display search bar on Advanced Search' do
    visit '/advanced'
    expect(page).not_to have_selector '.navbar-search'
  end
end