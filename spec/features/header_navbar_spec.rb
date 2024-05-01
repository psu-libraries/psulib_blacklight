# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Header Navbar' do
  it 'displays search bar except on Advanced Search' do
    visit root_path
    expect(page).to have_css '.navbar-search'
  end

  it 'does not display search bar on Advanced Search' do
    visit '/advanced'
    expect(page).to have_no_css '.navbar-search'
  end
end
