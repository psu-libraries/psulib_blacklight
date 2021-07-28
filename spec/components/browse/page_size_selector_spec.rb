# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Browse::PageSizeSelector, type: :component do
  let(:node) { render_inline(described_class.new(params: params)) }
  let(:button) { node.css('#page-size-btn').first }
  let(:params) { { nearby: 'abc' } }

  context 'when the length param is not provided' do
    specify do
      expect(button.text).to include('10 per page')
    end
  end

  context 'when the length param is explicitly provided' do
    let(:params) { { length: 50 } }

    specify do
      expect(button.text).to include('50 per page')
    end
  end

  it 'shows the correct page size options with correct links' do
    expect(node).to have_link('10', href: '/browse?length=10&nearby=abc')
    expect(node).to have_link('20', href: '/browse?length=20&nearby=abc')
    expect(node).to have_link('50', href: '/browse?length=50&nearby=abc')
    expect(node).to have_link('100', href: '/browse?length=100&nearby=abc')
  end
end
