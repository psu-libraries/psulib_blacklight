# frozen_string_literal: true

# spec/services/search_limit_service_spec.rb
require 'rails_helper'

RSpec.describe SearchLimitService do
  subject(:service) { described_class.new(params) }

  before do
    allow(ENV).to receive(:fetch).with('QUERY_CHAR_LIMIT', 45).and_return('45')
  end

  describe '#search_volume_exceeded?' do
    context 'when the search has more than 45 characters' do
      let(:params) do
        { 'q' => 'Literature Review: If Jurassic Park had valued IT, everyone would have lived' }
      end

      it 'returns true' do
        expect(service.search_volume_exceeded?).to be true
      end
    end

    context 'when the search has fewer than 45 characters' do
      context 'when the search has 1 facet and more than 30 characters' do
        let(:params) do
          {
            'q' => 'Jurassic Park and The Lost World',
            'f' => { 'format' => ['Book'] }
          }
        end

        it 'returns true' do
          expect(service.search_volume_exceeded?).to be true
        end
      end

      context 'when the search has 1 facet and fewer than 30 characters' do
        let(:params) do
          {
            'q' => 'Jurassic Park',
            'f' => { 'format' => ['Book'] }
          }
        end

        it 'returns false' do
          expect(service.search_volume_exceeded?).to be false
        end
      end
    end

    context 'when the search has more than 3 search fields' do
      let(:params) do
        {
          'f_inclusive' => {
            'access_facet' => ['In the Library'],
            'format' => ['Book'],
            'language_facet' => ['English'],
            'location_facet' => ['Paterno - 4th Floor']
          }
        }
      end

      it 'returns true' do
        expect(service.search_volume_exceeded?).to be true
      end
    end
  end
end
