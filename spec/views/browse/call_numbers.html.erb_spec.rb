# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'browse/call_numbers', type: :view do
  before do
    assign(:shelf_list, instance_spy(ShelfListPresenter, list: []))
    render
  end

  it 'renders an error message when there are no items to show' do
    expect(rendered).not_to have_selector 'table'
    expect(rendered).to have_selector '.alert-warning h2', text: 'No records found.'
  end
end
