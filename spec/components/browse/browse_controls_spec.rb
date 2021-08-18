# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Browse::BrowseControls, type: :component do
  let(:node) { render_inline(described_class.new(prev_item: prev_item,
                                                 next_item: next_item,
                                                 params: params)) }

  let(:button) { node.css('#page-size-btn').first }

  let(:prev_item) { ShelfItem.new(call_number: 'CALL1', key: 'KEY1') }
  let(:next_item) { ShelfItem.new(call_number: 'CALL2', key: 'KEY2') }
  let(:params) { { length: 50 } }

  it 'renders the correct UI elements' do
    expect(node).to have_selector '.btn-primary',
                                  exact_text: 'Previous'

    expect(node).to have_selector '.btn-primary',
                                  exact_text: 'Next'

    expect(button.text).to include '50 per page'
  end
end
