# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_header_navbar', type: :view do
  let(:blacklight_config) { Blacklight::Configuration.new }

  before do
    stub_template 'shared/_user_util_links.html.erb' => 'Some content'
    stub_template 'catalog/_search_form.html.erb' => 'Other content'
    assign(:search_bar, Blacklight::SearchBarPresenter.new(controller, blacklight_config))
  end

  xit 'displays search bar except on Advanced Search' do
    render 'shared/header_navbar'
    expect(rendered).to have_selector '.navbar-search'
  end

  xit 'does not display search bar on Advanced Search' do
    assign(:search_fields_for_advanced_search, :search_bar)
    render 'shared/header_navbar'
    expect(rendered).not_to have_selector '.navbar-search'
  end
end
