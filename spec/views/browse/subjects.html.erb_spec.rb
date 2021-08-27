# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'browse/subjects', type: :view do
  before do
    controller.params = {}
    assign(:subject_list, instance_spy(SubjectList, entries: []))
    render
  end

  it 'renders an error message when there are no items to show' do
    expect(rendered).not_to have_selector 'table'
    expect(rendered).to have_selector '.alert-warning h2', text: 'No records found.'
  end
end
