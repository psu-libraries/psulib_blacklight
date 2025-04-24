# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'browse/authors' do
  before do
    controller.params = { action: 'authors' }
    assign(:author_list, instance_spy(BrowseList, entries: []))
    render
  end

  it 'renders an error message when there are no items to show' do
    expect(rendered).to have_no_css 'table'
    expect(rendered).to have_css '.alert-warning h4',
                                 text: 'No authors found. Try the following tips to revise your search:'
    expect(rendered).to have_css 'ol'
  end
end
