# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Browse::CallNumberNavigation, type: :component do
  let(:node) { render_inline(described_class.new(list: mock_list)) }
  let(:mock_list) { instance_spy(ShelfListPresenter, previous_item: prev_item, next_item: next_item) }

  before {
 allow_any_instance_of(described_class).to receive(:params).and_return({ length: 20, action: 'call_numbers',
                                                                         classification: classification }) }

  context 'when Browse by LC Call Number' do
    let(:classification) { 'lc' }

    context 'when the shelf list has no previous page' do
      let(:next_item) { ShelfItem.new(call_number: 'CALL1', key: 'KEY1') }
      let(:prev_item) { nil }

      specify do
        expect(node).to have_no_link('Previous')
        expect(node).to have_link('Next', href: '/browse/call_numbers?classification=lc&length=20&starting=KEY1')
      end
    end

    context 'when the shelf list has no next page' do
      let(:prev_item) { ShelfItem.new(call_number: 'CALL2', key: 'KEY2') }
      let(:next_item) { nil }

      specify do
        expect(node).to have_link('Previous', href: '/browse/call_numbers?classification=lc&ending=KEY2&length=20')
        expect(node).to have_no_link('Next')
      end
    end

    context 'when the shelf list has both a previous and a next page' do
      let(:prev_item) { ShelfItem.new(call_number: 'CALL1', key: 'KEY1') }
      let(:next_item) { ShelfItem.new(call_number: 'CALL2', key: 'KEY2') }

      specify do
        expect(node).to have_link('Previous', href: '/browse/call_numbers?classification=lc&ending=KEY1&length=20')
        expect(node).to have_link('Next', href: '/browse/call_numbers?classification=lc&length=20&starting=KEY2')
      end
    end

    context 'when the shelf list has neither a previous nor a next page' do
      let(:prev_item) { nil }
      let(:next_item) { nil }

      specify do
        expect(node).to have_no_link('Previous')
        expect(node).to have_no_link('Next')
      end
    end
  end

  context 'when Browse by DEWEY Call Number' do
    let(:classification) { 'dewey' }

    context 'when the shelf list has no previous page' do
      let(:next_item) { ShelfItem.new(call_number: 'CALL1', key: 'KEY1') }
      let(:prev_item) { nil }

      specify do
        expect(node).to have_no_link('Previous')
        expect(node).to have_link('Next', href: '/browse/call_numbers?classification=dewey&length=20&starting=KEY1')
      end
    end

    context 'when the shelf list has no next page' do
      let(:prev_item) { ShelfItem.new(call_number: 'CALL2', key: 'KEY2') }
      let(:next_item) { nil }

      specify do
        expect(node).to have_link('Previous', href: '/browse/call_numbers?classification=dewey&ending=KEY2&length=20')
        expect(node).to have_no_link('Next')
      end
    end

    context 'when the shelf list has both a previous and a next page' do
      let(:prev_item) { ShelfItem.new(call_number: 'CALL1', key: 'KEY1') }
      let(:next_item) { ShelfItem.new(call_number: 'CALL2', key: 'KEY2') }

      specify do
        expect(node).to have_link('Previous', href: '/browse/call_numbers?classification=dewey&ending=KEY1&length=20')
        expect(node).to have_link('Next', href: '/browse/call_numbers?classification=dewey&length=20&starting=KEY2')
      end
    end

    context 'when the shelf list has neither a previous nor a next page' do
      let(:prev_item) { nil }
      let(:next_item) { nil }

      specify do
        expect(node).to have_no_link('Previous')
        expect(node).to have_no_link('Next')
      end
    end
  end
end
