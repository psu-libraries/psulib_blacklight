# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'browse/titles' do
  before do
    controller.params = { action: 'titles' }
    assign(:title_list, instance_spy(BrowseList, entries: []))
    render
  end

  it 'renders an error message when there are no items to show' do
    expect(rendered).to have_no_table
    expect(rendered).to have_css '.alert-warning h2', text: 'No records found.'
  end
end
