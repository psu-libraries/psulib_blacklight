# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Browse::CallNumberToggle, type: :component do
  context 'when list and id params are present' do
    let(:instance) do
      described_class.new(list: ['ABC'], id: '123')
    end

    let (:node) { render_inline(instance) }

    it 'renders the component' do
      expect(node).to have_selector('#moreCallNumbers123Btn')
    end
  end

  context 'when the list param is not present' do
    let(:instance) do
      described_class.new(list: nil, id: '123')
    end

    it 'does not render the component' do
      expect(instance.render?).to be false
    end
  end

  context 'when the id param is not present' do
    let(:instance) do
      described_class.new(list: ['ABC'], id: nil)
    end

    it 'does not render the component' do
      expect(instance.render?).to be false
    end
  end
end
