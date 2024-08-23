# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PsulConstraintsComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(search_state: search_state))
  end

  let(:search_state) { Blacklight::SearchState.new(params.with_indifferent_access, blacklight_config) }
  let(:params) { { f: { field1: %w[a b], field2: ['z'] } } }
  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.add_facet_field 'field1'
      config.add_facet_field 'field2'
    end
  end

  before do
    allow(Blacklight::SearchState).to receive(:new).and_return(search_state, search_state)
  end

  it 'renders constraints container' do
    expect(rendered).to have_css('div.constraints-container')
  end

  it 'does not render a start over link' do
    expect(rendered).to have_no_link('Start Over')
  end
end
