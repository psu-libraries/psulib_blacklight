# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Browse::NearbyButton, type: :component do
  let(:node) { render_inline(described_class.new(call_numbers: call_numbers, classification: classification)) }

  context 'when there is only one LC call number' do
    let(:call_numbers) { ['ABC'] }
    let(:classification) { 'lc' }

    it 'renders a simple button' do
      expect(node).not_to have_selector('button[data-toggle=dropdown]')
      expect(node).to have_link('Browse Nearby on Shelf', href: '/browse/call_numbers?classification=lc&nearby=ABC')
    end
  end

  context 'when there is only one Dewey call number' do
    let(:call_numbers) { ['131'] }
    let(:classification) { 'dewey' }

    it 'renders a simple button' do
      expect(node).not_to have_selector('button[data-toggle=dropdown]')
      expect(node).to have_link('Browse Nearby on Shelf', href: '/browse/call_numbers?classification=dewey&nearby=131')
    end
  end

  context 'when there are multiple LC call numbers' do
    let(:call_numbers) { ['ABC', 'DEF'] }
    let(:classification) { 'lc' }

    it 'renders a dropdown button with multiple options' do
      expect(node).to have_selector('button[data-toggle=dropdown]')
      expect(node).to have_link('ABC', href: '/browse/call_numbers?classification=lc&nearby=ABC')
      expect(node).to have_link('DEF', href: '/browse/call_numbers?classification=lc&nearby=DEF')
    end
  end

  context 'when there are multiple Dewey call numbers' do
    let(:call_numbers) { ['131', '132'] }
    let(:classification) { 'dewey' }

    it 'renders a dropdown button with multiple options' do
      expect(node).to have_selector('button[data-toggle=dropdown]')
      expect(node).to have_link('ABC', href: '/browse/call_numbers?classification=dewey&nearby=131')
      expect(node).to have_link('DEF', href: '/browse/call_numbers?classification=dewey&nearby=132')
    end
  end
end
