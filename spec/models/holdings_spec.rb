# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Holdings do
  describe '::METADATA_FIELDS' do
    specify do
      expect(described_class::METADATA_FIELDS).to contain_exactly(
        'author_person_display_ssm',
        'edition_display_ssm',
        'format',
        'id',
        'overall_imprint_display_ssm',
        'publication_display_ssm',
        'title_display_ssm'
      )
    end
  end

  context 'when a shelf key occurs only once in the document set' do
    let(:holdings) do
      described_class.new(
        documents: [document1, document2, document3],
        direction: 'forward'
      )
    end

    let(:document1) do
      {
        'id' => '1',
        'keymap_struct' => [[{ forward_key: 'forward_key_1', call_number: 'Solr Doc 1' }].to_json],
        'title_display_ssm' => 'Title 1'
      }
    end

    let(:document2) do
      {
        'id' => '2',
        'keymap_struct' => [[{ forward_key: 'forward_key_2', call_number: 'Solr Doc 2' }].to_json],
        'title_display_ssm' => 'Title 2'
      }
    end

    let(:document3) do
      {
        'id' => '3',
        'keymap_struct' => [[{ forward_key: 'forward_key_3', call_number: 'Solr Doc 3' }].to_json],
        'title_display_ssm' => 'Title 3'
      }
    end

    specify do
      expect(holdings.items.length).to eq(3)
      item = holdings.find('forward_key_1')
      expect(item.call_number).to eq('Solr Doc 1')
      expect(item.documents.map { |document| document['title_display_ssm'] }).to contain_exactly('Title 1')
    end
  end

  context 'when a shelf key occurs twice in the document set' do
    let(:holdings) do
      described_class.new(
        documents: [document1, document2, document3],
        direction: 'forward'
      )
    end

    let(:document1) do
      {
        'id' => '1',
        'keymap_struct' => [[{ forward_key: 'forward_key_1', call_number: 'Solr Doc 1' }].to_json],
        'title_display_ssm' => 'Title 1'
      }
    end

    let(:document2) do
      {
        'id' => '2',
        'keymap_struct' => [[{ forward_key: 'forward_key_1', call_number: 'Solr Doc 1' }].to_json],
        'title_display_ssm' => 'Title 2'
      }
    end

    let(:document3) do
      {
        'id' => '3',
        'keymap_struct' => [[{ forward_key: 'forward_key_3', call_number: 'Solr Doc 3' }].to_json],
        'title_display_ssm' => 'Title 3'
      }
    end

    specify do
      expect(holdings.items.length).to eq(2)
      item = holdings.find('forward_key_1')
      expect(item.call_number).to eq('Solr Doc 1')
      expect(item.documents.map { |document| document['title_display_ssm'] }).to contain_exactly('Title 1', 'Title 2')
    end
  end

  context 'when there is no keymap struct' do
    subject do
      described_class.new(
        documents: [{ 'id' => '1', 'title_display_ssm' => 'No Call Number' }],
        direction: 'forward'
      )
    end

    its(:items) { is_expected.to be_empty }
  end
end
