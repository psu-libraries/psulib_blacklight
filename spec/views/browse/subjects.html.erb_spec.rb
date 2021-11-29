# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'browse/subjects', type: :view do
  before do
    controller.params = { action: 'subjects' }
    assign(:subject_list, instance_spy(BrowseList, entries: []))
    render
  end

  it 'renders an error message when there are no items to show' do
    expect(rendered).not_to have_selector 'table'
    expect(rendered).to have_selector '.alert-warning h4',
                                      text: 'No subjects found. Try the following tips to revise your search:'
    expect(rendered).to have_selector 'ol'
  end
end
