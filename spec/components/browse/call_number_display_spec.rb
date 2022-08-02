# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Browse::CallNumberDisplay, type: :component do
  context 'when the call number and id params are present' do
    let(:instance) do
      described_class.new(call_number: 'ABC',
                          id: '123',
                          list: nil)
    end

    let(:node) { render_inline(instance) }

    it 'renders the component' do
      expect(node).to have_link('ABC', href: '/catalog/123')
    end
  end

  context 'when the call number is not present' do
    let(:instance) do
      described_class.new(call_number: nil,
                          id: '123',
                          list: nil)
    end

    it 'does not render the component' do
      expect(instance.render?).to be false
    end
  end

  context 'when the id is not present' do
    let(:instance) do
      described_class.new(call_number: 'ABC',
                          id: nil,
                          list: nil)
    end

    it 'does not render the component' do
      expect(instance.render?).to be false
    end
  end
end
