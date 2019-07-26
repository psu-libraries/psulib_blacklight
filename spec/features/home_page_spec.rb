# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Home Page', type: :feature do
  before do
    visit root_path
  end

  it 'does not render any facets' do
    expect(page).not_to have_css('#facets')
  end
end
