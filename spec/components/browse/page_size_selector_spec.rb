# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Browse::PageSizeSelector, type: :component do
  let(:node) { render_inline(described_class.new) }
  let(:button) { node.css('#page-size-btn').first }

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
      }.to raise_error(NoMethodError, starting_with("undefined method `browse_bogus_path'"))
    end
  end

  describe 'call number page selectors' do
    before { controller.params = { nearby: 'abc', action: 'index' } }

    context 'when the length param is not provided' do
      specify do
        expect(button.text).to include('10 per page')
      end
    end

    context 'when the length param is explicitly provided' do
      before { controller.params = { length: 50, action: 'index' } }

      specify do
        expect(button.text).to include('50 per page')
      end
    end

    it 'shows the correct page size options with correct links' do
      expect(node).to have_link('10', href: '/browse?length=10&nearby=abc')
      expect(node).to have_link('20', href: '/browse?length=20&nearby=abc')
      expect(node).to have_link('50', href: '/browse?length=50&nearby=abc')
    end
  end

  describe 'subject page selectors' do
    before { controller.params = { action: 'subjects' } }

    context 'when the length param is not provided' do
      specify do
        expect(button.text).to include('10 per page')
      end
    end

    context 'when the length param is explicitly provided' do
      before { controller.params = { length: 50, action: 'subjects' } }

      specify do
        expect(button.text).to include('50 per page')
      end
    end

    it 'shows the correct page size options with correct links' do
      expect(node).to have_link('10', href: '/browse/subjects?length=10')
      expect(node).to have_link('20', href: '/browse/subjects?length=20')
      expect(node).to have_link('50', href: '/browse/subjects?length=50')
    end
  end
end
