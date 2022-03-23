# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShelfQuery do
  subject(:docs) { described_class.call(field: 'forward_lc_shelfkey', limit: 5, query: '0') }

  let(:mock_index) { instance_spy('Blacklight::Solr::Repository', connection: mock_connection) }
  let(:mock_connection) { instance_spy('RSolr::Client') }

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
          'response' => {
            'docs' => {
              'forward_lc_shelfkey' => [
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
              ]
            }
          }
        }
      )
    end

    it 'does stuff' do
      expect(docs[:forward_lc_shelfkey]).to contain_exactly(
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
      )
    end
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
          'response' => {
            'docs' => {
              'forward_lc_shelfkey' => [
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
              ]
            }
          }
        }
      )
    end

    it { expect(docs[:forward_lc_shelfkey]).to contain_exactly(
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
