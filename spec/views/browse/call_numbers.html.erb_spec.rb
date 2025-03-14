# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'browse/call_numbers' do
  before do
    assign(:shelf_list, instance_spy(ShelfListPresenter, list: [], classification: classification))
    render
  end

  context 'when Browse by LC Call Number' do
    let (:classification) { 'lc' }

    it 'renders an error message when there are no items to show' do
      expect(rendered).to have_css 'h1', text: 'Browse by LC Call Number'
      expect(rendered).to have_no_css 'table'
      expect(rendered).to have_css '.alert-warning h2', text: 'No records found.'
    end
  end

  context 'when Browse by DEWEY Call Number' do
    let (:classification) { 'dewey' }

    it 'renders an error message when there are no items to show' do
      expect(rendered).to have_css 'h1', text: 'Browse by DEWEY Call Number'
      expect(rendered).to have_no_css 'table'
      expect(rendered).to have_css '.alert-warning h2', text: 'No records found.'
    end
  end
end
