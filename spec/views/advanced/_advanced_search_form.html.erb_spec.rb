# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'advanced/advanced_search_form', type: :view do
  let(:context) { {} }

  let(:config) { Blacklight::Configuration.new }

  before do
    stub_template 'advanced/_advanced_search_fields.html.erb' => 'Advanced Search Fields'
    stub_template 'advanced/_advanced_search_facets.html.erb' => 'Advanced Search Facets'
    stub_template 'advanced/_advanced_search_submit_btns.html.erb' => 'Advanced Search Submit Buttons'
  end

  it 'renders an additional search button at the top of the form' do
    render 'advanced/advanced_search_form', advanced_search_context: context, blacklight_config: config

    expect(rendered).to have_selector 'form h1.page-header input#advanced-search-submit-top'
  end
end
