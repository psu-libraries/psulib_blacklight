# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Holdings do
  let(:shelfkey_field) { 'shelfkey' }

  context 'when a shelf key occurs only once in the document set' do
    let(:holdings) do
      described_class.new([document1, document2, document3], shelfkey_field)
    end

    let(:document1) do
      {
        'id' => '1',
        'shelfkey' => ['key_1'],
        'keymap_struct' => [[{ key: 'key_1', call_number: 'Solr Doc 1' }].to_json],
        'title_display_ssm' => 'Title 1'
      }
    end

    let(:document2) do
      {
        'id' => '2',
        'shelfkey' => ['key_2'],
        'keymap_struct' => [[{ key: 'key_2', call_number: 'Solr Doc 2' }].to_json],
        'title_display_ssm' => 'Title 2'
      }
    end

    let(:document3) do
      {
        'id' => '3',
        'shelfkey' => ['key_3', 'key_4'],
        'keymap_struct' => [[{ key: 'key_3', call_number: 'Solr Doc 3' },
                             { key: 'key_4', call_number: 'Solr Doc 4' }].to_json],
        'title_display_ssm' => 'Title 3'
      }
    end

    specify do
      expect(holdings.items.length).to eq(4)
      item = holdings.find('key_1')
      expect(item.call_number).to eq('Solr Doc 1')
      expect(item.documents.map { |document| document['title_display_ssm'] }).to contain_exactly('Title 1')
    end
  end

  context 'when a shelf key occurs twice in the document set' do
    let(:holdings) do
      described_class.new([document1, document2, document3], shelfkey_field)
    end

    let(:document1) do
      {
        'id' => '1',
        'shelfkey' => ['key_1'],
        'keymap_struct' => [[{ key: 'key_1', call_number: 'Solr Doc 1' }].to_json],
        'title_display_ssm' => 'Title 1'
      }
    end

    let(:document2) do
      {
        'id' => '2',
        'shelfkey' => ['key_1'],
        'keymap_struct' => [[{ key: 'key_1', call_number: 'Solr Doc 1' }].to_json],
        'title_display_ssm' => 'Title 2'
      }
    end

    let(:document3) do
      {
        'id' => '3',
        'shelfkey' => ['key_3', 'key_4'],
        'keymap_struct' => [[{ key: 'key_3', call_number: 'Solr Doc 3' },
                             { key: 'key_4', call_number: 'Solr Doc 4' }].to_json],
        'title_display_ssm' => 'Title 3'
      }
    end

    specify do
      expect(holdings.items.length).to eq(3)
      item = holdings.find('key_1')
      expect(item.call_number).to eq('Solr Doc 1')
      expect(item.documents.map { |document| document['title_display_ssm'] }).to contain_exactly('Title 1', 'Title 2')
    end
  end

  context 'when there is no keymap struct' do
    subject do
      described_class.new([{ 'id' => '1', 'title_display_ssm' => 'No Call Number' }], shelfkey_field)
    end

    its(:items) { is_expected.to be_empty }
  end
end
