# frozen_string_literal: true

require 'rails_helper'

CHARS = ('0'..'9').to_a + ('A'..'Z').to_a

RSpec.describe ShelfList do
  describe '#documents' do
    # These tests are based off of our existing sample data. If our fixture data changes, these tests may break as a
    # result, requiring them to be updated, but it should not indicate that the ShelfList class itself is at fault.

    context 'when Browse by LC Call Number' do
      let(:classification) { 'lc' }

      context 'when querying with shelf key that is present in the library' do
        let(:list) do
          described_class.call(
            query: 'G..5761.F7.1963.G7',
            forward_limit: 5,
            reverse_limit: 5,
            classification: classification
          )
        end

        it 'returns the thing itself and the next five books that appear after it' do
          expect(list[:after].map(&:call_number)).to include(
            'G5761.F7 1963.G7',
            'G7273.T5 1968.S6',
            'G8961.C5 1931.D3',
            'GN320.G66 1993',
            'GV979.S9B43 2005 DVD',
            'GV979.S9B43 2005 DVD'
          )
        end

        it 'returns the previous four books that appear before it in reverse order, but not the thing itself' do
          expect(list[:before].map(&:call_number)).to contain_exactly(
            'F2230.1.F6L413 1973',
            'G125.M7665 1885',
            'G3803.W3J3 1956.N4',
            'G3823.D3P2 1988.P4',
            'G4831.P2 1950.G4'
          )
        end
      end

      context 'when querying using a shelf key that is not present in library' do
        let(:list) do
          described_class.call(
            query: 'ML.B101.X7.1981.A5',
            forward_limit: 5,
            reverse_limit: 5,
            classification: classification
          )
        end

        it 'returns the next five books that appear after it' do
          expect(list[:after].map(&:call_number)).to include(
            'N7277.G36 1957 Q',
            'N7279.R33P3 1940',
            'N7433.4.M69I54 2005',
            'NB977.G35 1956 Q',
            'NC980.A8 no.11'
          )
        end

        it 'returns the the previous five books that appear before it in reverse order' do
          expect(list[:before].map(&:call_number)).to contain_exactly(
            'M2000.S151S3 1998 CD',
            'M2000.S56M57 2009 CD',
            'M2000.T244C5 1986 CD',
            'M2000.U55I25 2000 CD',
            'M2000.Z33Z3 1997 CD'
          )
        end
      end
    end

    context 'when Browse by DEWEY Call Number' do
      let(:classification) { 'dewey' }

      context 'when querying with shelf key that is present in the library' do
        let(:list) do
          described_class.call(
            query: 'AAA0301154.G854-C',
            forward_limit: 5,
            reverse_limit: 5,
            classification: classification
          )
        end

        it 'returns the thing itself and the next five things that appear after it' do
          expect(list[:after].map(&:call_number)).to include(
            '301.154G854c',
            '329.942L113za 1949',
            '331.21H529t 1957',
            '331.21H529t 1964',
            '332.1M58p',
            '332.7P384'
          )
        end

        it 'returns the previous four things that appear before it in reverse order, but not the thing itself' do
          expect(list[:before].map(&:call_number)).to contain_exactly(
            '111.85M35b',
            '136.53M582a',
            '170M366l 1844',
            '294.516B14b Zs',
            '301.154G854c'
          )
        end
      end

      context 'when querying using a shelf key that is not present in library' do
        let(:list) do
          described_class.call(
            query: 'AAA0333--JTS0091V00010002',
            forward_limit: 5,
            reverse_limit: 5,
            classification: classification
          )
        end

        it 'returns the next five things that appear after it' do
          expect(list[:after].map(&:call_number)).to include(
            '333.91In8r',
            '333.91Inl v.1-3 no.2 Dec.1951-Feb.1953',
            '378.242P68b',
            '547.05J826',
            '581.96F669'
          )
        end

        it 'returns the the previous five things that appear before it in reverse order' do
          expect(list[:before].map(&:call_number)).to contain_exactly(
            '329.942L113za 1949',
            '331.21H529t 1957',
            '331.21H529t 1964',
            '332.1M58p',
            '332.7P384'
          )
        end
      end
    end
  end
end
