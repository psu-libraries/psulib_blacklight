# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Browse::PrefixSelector, type: :component do
  let(:node) { render_inline(described_class.new) }

  context 'when no action can be determined' do
    specify do
      expect {
        node
      }.to raise_error(KeyError, 'params must include :action')
    end
  end

  context 'when there is no corresponding path method for the action' do
    before { controller.params = { action: 'bogus' } }

    specify do
      expect {
        node
      }.to raise_error(ArgumentError, "no path defined for 'bogus'")
    end
  end

  context 'when no prefix is specified' do
    before { controller.params = { action: 'subjects' } }

    it "renders the selectors with 'All' active" do
      expect(node.css('li.active').count).to eq(1)
      expect(node).to have_selector('li', class: 'active', text: 'All')

      ('A'..'Z').to_a.each do |letter|
        expect(node).to have_link(letter)
      end
    end
  end

  context 'with a specified prefix' do
    before { controller.params = { action: 'subjects', prefix: 'E' } }

    it 'renders the selector as active' do
      expect(node.css('li.active').count).to eq(1)
      expect(node).to have_selector('li', class: 'active', text: 'E')
    end
  end

  context 'when length is present as a parameter' do
    before { controller.params = { action: 'subjects', length: '20' } }

    it 'retains the parameter in the urls' do
      ('A'..'Z').to_a.each do |letter|
        expect(node).to have_link(letter, href: "/browse/subjects?length=20&prefix=#{letter}")
      end
    end
  end
end
