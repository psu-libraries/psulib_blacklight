# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Browse::PrefixSelector, type: :component do
  let(:node) { render_inline(described_class.new) }

  context 'when no prefix is specified' do
    it "renders the selectors with 'All' active" do
      expect(node.css('li.active').count).to eq(1)
      expect(node).to have_selector('li', class: 'active', text: 'All')

      ('A'..'Z').to_a.each do |letter|
        expect(node).to have_link(letter)
      end
    end
  end

  context 'with a specified prefix' do
    before { controller.params = { prefix: 'E' } }

    it 'renders the selector as active' do
      expect(node.css('li.active').count).to eq(1)
      expect(node).to have_selector('li', class: 'active', text: 'E')
    end
  end

  context 'when length is present as a parameter' do
    before { controller.params = { length: '20' } }

    it 'retains the parameter in the urls' do
      ('A'..'Z').to_a.each do |letter|
        expect(node).to have_link(letter, href: "/browse/subjects?length=20&prefix=#{letter}")
      end
    end
  end
end
