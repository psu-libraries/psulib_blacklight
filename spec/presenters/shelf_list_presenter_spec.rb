# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShelfListPresenter, type: :model do
  let(:classification) { 'lc' }
  let(:first) { ShelfItem.new(call_number: 'first', key: 'first') }
  let(:previous_shelf) { ShelfItem.new(call_number: 'previous_shelf', key: 'previous_shelf') }
  let(:first_book) { ShelfItem.new(call_number: 'first_book', key: 'first_book') }
  let(:middle_book) { ShelfItem.new(call_number: 'middle_book', key: 'middle_book') }
  let(:last_book) { ShelfItem.new(call_number: 'last_book', key: 'last_book') }
  let(:next_shelf) { ShelfItem.new(call_number: 'next_shelf', key: 'next_shelf') }
  let(:last) { ShelfItem.new(call_number: 'last', key: 'last') }

  describe '#empty?' do
    it { is_expected.to delegate_method(:empty?).to :list }
  end

  describe '#length' do
    context 'with defaults' do
      its(:length) { is_expected.to eq(20) }
    end

    context 'when overriding' do
      subject { described_class.new(length: 50) }

      its(:length) { is_expected.to eq(50) }
    end

    context 'when set too small' do
      subject { described_class.new(length: described_class::MIN - 1) }

      its(:length) { is_expected.to eq(described_class::MIN) }
    end

    context 'when set too large' do
      subject { described_class.new(length: described_class::MAX + 1) }

      its(:length) { is_expected.to eq(described_class::MAX) }
    end
  end

  context 'when starting at the first' do
    let(:shelf) { described_class.new(length: 3, classification: classification) }

    before do
      allow(ShelfList).to receive(:call)
        .with({ query: 'A', reverse_limit: 0, forward_limit: 4, classification: classification })
        .and_return(
          {
            before: [],
            after: [first, middle_book, last_book, next_shelf]
          }
        )
    end

    specify do
      expect(shelf.list.map(&:call_number)).to eq(['first', 'middle_book', 'last_book'])
      expect(shelf.next_item.call_number).to eq('next_shelf')
      expect(shelf.previous_item).to be_nil
    end
  end

  context 'when browsing forward with exact matches' do
    let(:shelf) { described_class.new(length: 3, starting: :first_book, classification: classification) }

    before do
      allow(ShelfList).to receive(:call)
        .with({ query: :first_book, reverse_limit: 2, forward_limit: 3, classification: classification })
        .and_return(
          {
            before: [first_book, previous_shelf],
            after: [middle_book, last_book, next_shelf]
          }
        )
    end

    specify do
      expect(shelf.list.map(&:call_number)).to eq(['first_book', 'middle_book', 'last_book'])
      expect(shelf.next_item.call_number).to eq('next_shelf')
      expect(shelf.previous_item.call_number).to eq('previous_shelf')
    end
  end

  context 'when browsing forward to the end' do
    let(:shelf) { described_class.new(length: 3, starting: :first_book, classification: classification) }

    before do
      allow(ShelfList).to receive(:call)
        .with({ query: :first_book, reverse_limit: 2, forward_limit: 3, classification: classification })
        .and_return(
          {
            before: [first_book, previous_shelf],
            after: [middle_book, last]
          }
        )
    end

    specify do
      expect(shelf.list.map(&:call_number)).to eq(['first_book', 'middle_book', 'last'])
      expect(shelf.next_item).to be_nil
      expect(shelf.previous_item.call_number).to eq('previous_shelf')
    end
  end

  context 'when browsing backward with exact matches' do
    let(:shelf) { described_class.new(length: 3, ending: :last_book, classification: classification) }

    before do
      allow(ShelfList).to receive(:call)
        .with({ query: :last_book, reverse_limit: 4, forward_limit: 1, classification: classification })
        .and_return(
          {
            before: [last_book, middle_book, first_book, previous_shelf],
            after: [next_shelf]
          }
        )
    end

    specify do
      expect(shelf.list.map(&:call_number)).to eq(['first_book', 'middle_book', 'last_book'])
      expect(shelf.next_item.call_number).to eq('next_shelf')
      expect(shelf.previous_item.call_number).to eq('previous_shelf')
    end
  end

  context 'when browsing backward to the end' do
    let(:shelf) { described_class.new(length: 3, ending: :last_book, classification: classification) }

    before do
      allow(ShelfList).to receive(:call)
        .with({ query: :last_book, reverse_limit: 4, forward_limit: 1, classification: classification })
        .and_return(
          {
            before: [last_book, middle_book, first],
            after: [next_shelf]
          }
        )
    end

    specify do
      expect(shelf.list.map(&:call_number)).to eq(['first', 'middle_book', 'last_book'])
      expect(shelf.next_item.call_number).to eq('next_shelf')
      expect(shelf.previous_item).to be_nil
    end
  end

  context 'when browsing nearby with an exact match' do
    let(:shelf) { described_class.new(length: 3, nearby: 'middle_book', classification: classification) }

    before do
      allow(ShelfList).to receive(:call)
        .with({ query: 'middle_book', reverse_limit: 3, forward_limit: 2, classification: classification })
        .and_return(
          {
            before: [middle_book, first_book, previous_shelf],
            after: [last_book, next_shelf]
          }
        )
    end

    specify do
      expect(shelf.list.map(&:call_number)).to eq(['first_book', 'middle_book', 'last_book'])
      expect(shelf.next_item.call_number).to eq('next_shelf')
      expect(shelf.previous_item.call_number).to eq('previous_shelf')
      expect(shelf.list[1]).to be_nearby
      expect(shelf.list[1]).to be_match
    end
  end

  context 'when browsing nearby with a non-matching query' do
    let(:shelf) { described_class.new(length: 3, nearby: 'unknown', classification: classification) }

    context 'when starting at the first' do
      before do
        allow(ShelfList).to receive(:call)
          .with({ query: 'unknown', reverse_limit: 3, forward_limit: 2, classification: classification })
          .and_return(
            {
              before: [],
              after: [first, middle_book, last_book, next_shelf]
            }
          )
      end

      specify do
        expect(shelf.list.map(&:call_number)).to eq(['None', 'first', 'middle_book'])
        expect(shelf.next_item.call_number).to eq('next_shelf')
        expect(shelf.previous_item).to be_nil
        expect(shelf.list[0]).to be_nearby
        expect(shelf.list[1]).not_to be_match
      end
    end

    context 'when not starting at the first' do
      before do
        allow(ShelfList).to receive(:call)
          .with({ query: 'unknown', reverse_limit: 3, forward_limit: 2, classification: classification })
          .and_return(
            {
              before: [first_book, previous_shelf, last_book],
              after: [last_book, next_shelf]
            }
          )
      end

      specify do
        expect(shelf.list.map(&:call_number)).to eq(['first_book', 'None', 'last_book'])
        expect(shelf.next_item.call_number).to eq('next_shelf')
        expect(shelf.previous_item.call_number).to eq('previous_shelf')
        expect(shelf.list[1]).to be_nearby
        expect(shelf.list[1]).not_to be_match
      end
    end
  end
end
