# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShelfItem do
  describe '#label' do
    context 'with no label and no documents' do
      subject { described_class.new(call_number: 'number', key: 'number') }

      its(:label) { is_expected.to eq('Unknown') }
    end

    context 'when providing a label' do
      subject { described_class.new(call_number: 'number', key: 'number', label: 'My Label') }

      its(:label) { is_expected.to eq('My Label') }
    end

    context 'when the document does not have a title' do
      subject(:item) { described_class.new(call_number: 'number', key: 'number') }

      before { item.add({}) }

      its(:label) { is_expected.to eq('No title found') }
    end

    context 'when the document has a title' do
      subject(:item) { described_class.new(call_number: 'number', key: 'number') }

      before { item.add({ 'title_display_ssm' => 'My Title' }) }

      its(:label) { is_expected.to eq('My Title') }
    end
  end

  describe '#match' do
    context 'with defaults' do
      subject { described_class.new(call_number: 'number', key: 'number') }

      it { is_expected.not_to be_match }
    end

    context 'when marking a matching item' do
      subject(:item) { described_class.new(call_number: 'number', key: 'number') }

      before { item.match = true }

      it { is_expected.to be_match }
    end
  end

  describe '#nearby' do
    context 'with defaults' do
      subject { described_class.new(call_number: 'number', key: 'number') }

      it { is_expected.not_to be_nearby }
    end

    context 'when marking a nearby item' do
      subject(:item) { described_class.new(call_number: 'number', key: 'number') }

      before { item.nearby = true }

      it { is_expected.to be_nearby }
    end
  end

  describe ShelfItem::DecoratedDocument do
    it 'extends SimpleDelegator' do
      expect(described_class).to be < SimpleDelegator
    end

    describe 'location_display' do
      it 'shows the correct text for a single location' do
        doc = described_class.new(SolrDocument.new({ 'library_facet': ['Library 1'] }))

        expect(doc.location_display).to eq 'Library 1'
      end

      it 'shows the correct text for 3 locations' do
        doc = described_class.new(SolrDocument.new({ 'library_facet': ['Lib 1', 'Lib 2', 'Lib 3'] }))

        expect(doc.location_display).to eq 'Lib 1 / Lib 2 / Lib 3'
      end

      it 'shows the correct text for 4 locations' do
        doc = described_class.new(SolrDocument.new({ 'library_facet': ['1', '2', '3', '4'] }))

        expect(doc.location_display).to eq 'Multiple Locations'
      end

      it 'returns nil if no library_facet is set' do
        doc = described_class.new(SolrDocument.new({}))

        expect(doc.location_display).to be_nil
      end
    end
  end
end
