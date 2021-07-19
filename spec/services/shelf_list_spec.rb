# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShelfList do
  subject(:list) { described_class.new(query) }

  # @note This is only until we get call numbers indexed via Traject
  before(:all) do
    Blacklight.default_index.connection.delete_by_query('*:*')

    100.times do
      Blacklight.default_index.connection.add RecordFactory.new.record
    end

    Blacklight.default_index.connection.commit
  end

  after(:all) do
    Blacklight.default_index.connection.delete_by_query('*:*')

    docs = File.open('spec/fixtures/current_fixtures.json').each_line.map { |l| JSON.parse(l) }
    Blacklight.default_index.connection.add(docs)

    Blacklight.default_index.connection.commit
  end

  describe '#forward' do
    context 'when call numbers come after the query' do
      let(:query) { 'AAA' }

      its(:forward) { is_expected.not_to be_empty }
    end

    context 'when NO call numbers come after the query' do
      let(:query) { 'ZZZ' }

      its(:forward) { is_expected.to be_empty }
    end
  end

  describe '#reverse' do
    context 'when call numbers come after the query' do
      let(:query) { 'AAA' }

      its(:reverse) { is_expected.not_to be_empty }
    end

    context 'when NO call numbers come after the query' do
      let(:query) { 'ZZZ' }

      its(:reverse) { is_expected.to be_empty }
    end
  end

  describe '#documents' do
    let(:query) { 'M' }

    it 'returns an ordered list of reverse and forward documents' do
      expect(list.documents.count).to eq(20)
    end
  end
end
