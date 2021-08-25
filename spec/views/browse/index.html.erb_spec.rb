# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'browse/index', type: :view do
  it 'renders an error message when there are no items to show' do
    @shelf_list = instance_double(ShelfListPresenter, list: [])

    render

    expect(rendered).not_to have_selector 'table'
    expect(rendered).to have_selector '.alert-warning h2', text: 'No records found.'
  end
end
