# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Browse::NearbyButton, type: :component do
  let(:node) { render_inline(described_class.new(call_numbers: call_numbers)) }

  context 'when there is only one call number' do
    let(:call_numbers) { ['ABC'] }

    it 'renders a simple button' do
      expect(node).not_to have_selector('button[data-toggle=dropdown]')
      expect(node).to have_link('Browse Nearby on Shelf', href: '/browse/call_numbers?nearby=ABC')
    end
  end

  context 'when there are multiple call numbers' do
    let(:call_numbers) { ['ABC', 'DEF'] }

    it 'renders a dropdown button with multiple options' do
      expect(node).to have_selector('button[data-toggle=dropdown]')
      expect(node).to have_link('ABC', href: '/browse/call_numbers?nearby=ABC')
      expect(node).to have_link('DEF', href: '/browse/call_numbers?nearby=DEF')
    end
  end
end
