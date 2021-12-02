# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrowseList do
  let(:mock_index) { instance_spy('Blacklight::Solr::Repository', connection: mock_connection) }
  let(:mock_connection) { instance_spy('RSolr::Client') }

  let(:response) do
    {
      'facet_counts' => {
        'facet_fields' => {
          'browsing_facet' => facet_results
        }
      }
    }
  end

  let(:facet_results) do
    ['term1', 1, 'TERM2', 3, 'term3', 5]
  end

  before do
    allow(Blacklight).to receive(:default_index).and_return(mock_index)
    allow(mock_connection).to receive(:get).with(any_args).and_return(response)
  end

  describe '#empty?' do
    subject { described_class.new(field: 'browsing_facet') }

    it { is_expected.to delegate_method(:empty?).to :entries }
  end

  describe '#entries' do
    context 'with no provided params' do
      specify do
        entries = described_class.new(field: 'browsing_facet').entries
        expect(mock_connection).to have_received(:get).with(
          'select',
          {
            params: {
              'facet' => 'true',
              'facet.field' => 'browsing_facet',
              'facet.limit' => 21,
              'facet.offset' => 0,
              'facet.prefix' => nil,
              'facet.sort' => 'index',
              'rows' => '0'
            }
          }
        )
        expect(entries).to contain_exactly(
          described_class::Entry.new('term1', 1),
          described_class::Entry.new('TERM2', 3),
          described_class::Entry.new('term3', 5)
        )
      end
    end

    context 'when providing page, length, and prefix' do
      specify do
        entries = described_class.new(
          field: 'browsing_facet',
          page: 2,
          length: 50,
          prefix: 'tE--rM--*'
        ).entries

        expect(mock_connection).to have_received(:get).with(
          'select',
          {
            params: {
              'facet' => 'true',
              'facet.field' => 'browsing_facet',
              'facet.limit' => 51,
              'facet.offset' => 50,
              'facet.prefix' => 'TE—rM—',
              'facet.sort' => 'index',
              'rows' => '0'
            }
          }
        )

        expect(entries).to contain_exactly(
          described_class::Entry.new('term1', 1),
          described_class::Entry.new('TERM2', 3),
          described_class::Entry.new('term3', 5)
        )
      end
    end
  end

  describe '#last_page?' do
    context 'when the number of results is less than the length of the page' do
      subject { described_class.new(field: 'browsing_facet', length: 5) }

      it { is_expected.to be_last_page }
    end

    context 'when the number of results is greater than the length of the page' do
      subject { described_class.new(field: 'browsing_facet', length: 2) }

      it { is_expected.not_to be_last_page }
    end
  end
end
