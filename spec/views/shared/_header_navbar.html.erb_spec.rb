# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_header_navbar' do
  let(:blacklight_config) { Blacklight::Configuration.new }

  before do
    stub_template 'shared/_user_util_links.html.erb' => 'Some content'
    stub_template 'catalog/_search_form.html.erb' => 'Other content'
    assign(:search_bar, Blacklight::SearchBarPresenter.new(controller, blacklight_config))
  end

  it 'displays search bar except on Advanced Search' do
    pending 'incomplete'
    render 'shared/header_navbar'
    expect(rendered).to have_css '.navbar-search'
  end

  it 'does not display search bar on Advanced Search' do
    pending 'incomplete'
    assign(:search_fields_for_advanced_search, :search_bar)
    render 'shared/header_navbar'
    expect(rendered).to have_no_css '.navbar-search'
  end
end
