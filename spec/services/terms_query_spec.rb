# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermsQuery do
  subject(:terms) { described_class.call(field: 'forward_lc_shelfkey', limit: 5, query: '0') }

  let(:mock_index) { instance_spy('Blacklight::Solr::Repository', connection: mock_connection) }
  let(:mock_connection) { instance_spy('RSolr::Client') }

  # @note The structure of the data response to a term query varies slightly depending on how many shards are configured
  # in Solr. Because it's not easy to replicate these differences locally, and it's only needed for this one test, we're
  # mocking the data response from Solr. We're also mocking _both_ responses, the one with 1 shard and the one with
  # multiple shards, because it better highlights the differences.

  before do
    allow(Blacklight).to receive(:default_index).and_return(mock_index)
    allow(mock_connection).to receive(:get).with(any_args).and_return(json_response)
  end

  context 'when the Solr configuration has only one shard' do
    # @note Technically, RSolr is returning RSolr::HashWithResponse but it's just a hash under the hood.
    let(:json_response) do
      HashWithIndifferentAccess.new(
        {
          'responseHeader' => {
            'zkConnected' => true,
            'status' => 0,
            'QTime' => 0
          },
          'terms' => {
            'forward_lc_shelfkey' => [
              'AN.0502.L66.M63', 2,
              'AP.0002.A8', 1,
              'AP.0002.N6763', 1,
              'AP.0002.O354', 1,
              'AP.0002.T37', 1,
              'AP.0002.T47', 1,
              'AP.0003.M33', 2,
              'AP.0050.U5--19770078', 1,
              'AP.0050.U5--19790080', 1,
              'AP.0050.U5--19810082', 1
            ]
          }
        }
      )
    end

    it { expect(terms).to contain_exactly(
      'AN.0502.L66.M63',
      'AP.0002.A8',
      'AP.0002.N6763',
      'AP.0002.O354',
      'AP.0002.T37',
      'AP.0002.T47',
      'AP.0003.M33',
      'AP.0050.U5--19770078',
      'AP.0050.U5--19790080',
      'AP.0050.U5--19810082'
    ) }
  end

  context 'when the Solr configuration has more than one shard' do
    # @note Technically, RSolr is returning RSolr::HashWithResponse but it's just a hash under the hood.
    let(:json_response) do
      HashWithIndifferentAccess.new(
        {
          'responseHeader' => {
            'zkConnected' => true,
            'status' => 0,
            'QTime' => 734
          },
          'terms' => {
            'forward_lc_shelfkey' => {
              'AC.0001.A4' => 1,
              'AC.0001.B75--NO00010002NO00061782' => 1,
              'AC.0001.E8' => 2,
              'AC.0001.G7' => 5,
              'AC.0001.G72' => 6,
              'AC.0001.L8' => 2,
              'AC.0004.L53.1839' => 1,
              'AC.0005.A85' => 1,
              'AC.0005.B8' => 1,
              'AC.0005.C565.1969' => 1
            }
          }
        }
      )
    end

    it { expect(terms).to contain_exactly(
      'AC.0001.A4',
      'AC.0001.B75--NO00010002NO00061782',
      'AC.0001.E8',
      'AC.0001.G7',
      'AC.0001.G72',
      'AC.0001.L8',
      'AC.0004.L53.1839',
      'AC.0005.A85',
      'AC.0005.B8',
      'AC.0005.C565.1969'
    ) }
  end
end
