# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShelfListPresenter, type: :model do
  let(:beginning) { SolrDocument.new({ call_number_ssm: ['beginning'] }) }
  let(:previous_shelf) { SolrDocument.new({ call_number_ssm: ['previous_shelf'] }) }
  let(:first_book) { SolrDocument.new({ call_number_ssm: ['first_book'] }) }
  let(:middle_book) { SolrDocument.new({ call_number_ssm: ['middle_book'] }) }
  let(:last_book) { SolrDocument.new({ call_number_ssm: ['last_book'] }) }
  let(:next_shelf) { SolrDocument.new({ call_number_ssm: ['next_shelf'] }) }
  let(:the_end) { SolrDocument.new({ call_number_ssm: ['the_end'] }) }

  describe '#length' do
    context 'with defaults' do
      its(:length) { is_expected.to eq(10) }
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

  context 'when starting at the beginning' do
    let(:shelf) { described_class.new(length: 3) }

    before do
      allow(ShelfList).to receive(:call)
        .with({ query: '0', reverse_limit: 0, forward_limit: 4 })
        .and_return(
          {
            before: [],
            after: [beginning, middle_book, last_book, next_shelf]
          }
        )
    end

    specify do
      expect(shelf.list.map(&:call_number)).to eq(['beginning', 'middle_book', 'last_book'])
      expect(shelf.next.call_number).to eq('next_shelf')
      expect(shelf.previous).to be_nil
    end
  end

  context 'when browsing forward with exact matches' do
    let(:shelf) { described_class.new(length: 3, starting: :first_book) }

    before do
      allow(ShelfList).to receive(:call)
        .with({ query: :first_book, reverse_limit: 2, forward_limit: 3 })
        .and_return(
          {
            before: [first_book, previous_shelf],
            after: [middle_book, last_book, next_shelf]
          }
        )
    end

    specify do
      expect(shelf.list.map(&:call_number)).to eq(['first_book', 'middle_book', 'last_book'])
      expect(shelf.next.call_number).to eq('next_shelf')
      expect(shelf.previous.call_number).to eq('previous_shelf')
    end
  end

  context 'when browsing forward to the end' do
    let(:shelf) { described_class.new(length: 3, starting: :first_book) }

    before do
      allow(ShelfList).to receive(:call)
        .with({ query: :first_book, reverse_limit: 2, forward_limit: 3 })
        .and_return(
          {
            before: [first_book, previous_shelf],
            after: [middle_book, the_end]
          }
        )
    end

    specify do
      expect(shelf.list.map(&:call_number)).to eq(['first_book', 'middle_book', 'the_end'])
      expect(shelf.next).to be_nil
      expect(shelf.previous.call_number).to eq('previous_shelf')
    end
  end

  context 'when browsing backward with exact matches' do
    let(:shelf) { described_class.new(length: 3, ending: :last_book) }

    before do
      allow(ShelfList).to receive(:call)
        .with({ query: :last_book, reverse_limit: 4, forward_limit: 1 })
        .and_return(
          {
            before: [last_book, middle_book, first_book, previous_shelf],
            after: [next_shelf]
          }
        )
    end

    specify do
      expect(shelf.list.map(&:call_number)).to eq(['first_book', 'middle_book', 'last_book'])
      expect(shelf.next.call_number).to eq('next_shelf')
      expect(shelf.previous.call_number).to eq('previous_shelf')
    end
  end

  context 'when browsing backward to the end' do
    let(:shelf) { described_class.new(length: 3, ending: :last_book) }

    before do
      allow(ShelfList).to receive(:call)
        .with({ query: :last_book, reverse_limit: 4, forward_limit: 1 })
        .and_return(
          {
            before: [last_book, middle_book, beginning],
            after: [next_shelf]
          }
        )
    end

    specify do
      expect(shelf.list.map(&:call_number)).to eq(['beginning', 'middle_book', 'last_book'])
      expect(shelf.next.call_number).to eq('next_shelf')
      expect(shelf.previous).to be_nil
    end
  end

  context 'when browsing nearby with an exact match' do
    let(:shelf) { described_class.new(length: 3, nearby: 'middle_book') }

    before do
      allow(ShelfList).to receive(:call)
        .with({ query: 'middle_book', reverse_limit: 3, forward_limit: 2 })
        .and_return(
          {
            before: [middle_book, first_book, previous_shelf],
            after: [last_book, next_shelf]
          }
        )
    end

    specify do
      expect(shelf.list.map(&:call_number)).to eq(['first_book', 'middle_book', 'last_book'])
      expect(shelf.next.call_number).to eq('next_shelf')
      expect(shelf.previous.call_number).to eq('previous_shelf')
      expect(shelf.list[1]).to be_nearby
      expect(shelf.list[1]).to be_exact_match
    end
  end

  context 'when browsing nearby with an non-matching query' do
    let(:shelf) { described_class.new(length: 3, nearby: 'unknown') }

    before do
      allow(ShelfList).to receive(:call)
        .with({ query: 'unknown', reverse_limit: 3, forward_limit: 2 })
        .and_return(
          {
            before: [first_book, previous_shelf, last_book],
            after: [last_book, next_shelf]
          }
        )
    end

    specify do
      expect(shelf.list.map(&:call_number)).to eq(['first_book', "You're looking for: unknown", 'last_book'])
      expect(shelf.next.call_number).to eq('next_shelf')
      expect(shelf.previous.call_number).to eq('previous_shelf')
      expect(shelf.list[1]).to be_nearby
      expect(shelf.list[1]).not_to be_exact_match
    end
  end
end
