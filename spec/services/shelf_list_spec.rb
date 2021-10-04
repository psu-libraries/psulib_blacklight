# frozen_string_literal: true

require 'rails_helper'

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

        it 'returns the next five books that appear after it, but not the book itself' do
          expect(list[:after].map(&:call_number)).to contain_exactly(
            'G7273.T5 1968.S6',
            'G8961.C5 1931.D3',
            'GN320.G66 1993',
            'GV979.S9B43 2005 DVD',
            'G5761.F7 1963.G7'
          )
        end

        it 'returns the book itself and the previous four books that appear before it in reverse order' do
          expect(list[:before].map(&:call_number)).to contain_exactly(
            'G125.M7665 1885',
            'G3803.W3J3 1956.N4',
            'G3823.D3P2 1988.P4',
            'G4831.P2 1950.G4',
            'GV1643.M36 no.2 1531'
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
          expect(list[:after].map(&:call_number)).to contain_exactly(
            'N7277.G36 1957 Q',
            'N7279.R33P3 1940',
            'N7433.4.M69I54 2005',
            'NB977.G35 1956 Q',
            'NC980.A8 no.11'
          )
        end

        it 'returns the the previous five books that appear before it in reverse order' do
          expect(list[:before].map(&:call_number)).to contain_exactly(
            'L16.D8',
            'LB1574.H638 1998 Level 2',
            'LB1574.H638 1998 Level 3',
            'LB1580.I75A63 2002',
            'LC1421.M83 1801 v.1-2'
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

        it 'returns the next five things that appear after it, but not the thing itself' do
          expect(list[:after].map(&:call_number)).to contain_exactly(
            '329.942L113za 1949',
            '331.21H529t 1957',
            '331.21H529t 1964',
            '332.1M58p',
            '332.7P384'
          )
        end

        it 'returns the thing itself and the previous four things that appear before it in reverse order' do
          expect(list[:before].map(&:call_number)).to contain_exactly(
            '136.53M582a',
            '136.53M582a Guidebook',
            '136.53M582a Readings',
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
          expect(list[:after].map(&:call_number)).to contain_exactly(
            '333.91In8r',
            '333.91Inl v.1-3 no.2 Dec.1951-Feb.1953',
            '378.242P68b',
            '547.05J826',
            '581.96F669'
          )
        end

        it 'returns the the previous five things that appear before it in reverse order' do
          expect(list[:before].map(&:call_number)).to contain_exactly(
            '331.21H529t 1964',
            '332.1M58p',
            '332.7P384',
            '333.91In8r',
            '333.91Inl v.1-3 no.2 Dec.1951-Feb.1953'
          )
        end
      end
    end

    # These tests should work regardless of any changes to our fixture data. Because they aren't tied directly to the
    # fixture data, they use an unorthodox testing strategy. We compare what the shelf list is creating based on the
    # term component query coming out of Solr. The easiest way to do that is compare the term query with the final
    # output generated from that query.
    #
    # If these tests are breaking, it is likely a problem with the service or with Solr.
    context 'when testing with randomized queries' do
      it 'returns a set of before and after items matching the original term query' do
        skip "I think these tests are too brittle and don't really help. We shoudl refactor or remove them"
        100.times do
          query = ShelfKey::FORWARD_CHARS.sample
          reverse_query = ShelfKey.reverse(query)
          forward_limit = (0..10).to_a.sample
          reverse_limit = (0..10).to_a.sample

          puts "      testing query: #{query}, forward_limit: #{forward_limit}, reverse_limit: #{reverse_limit}"

          list = described_class.call(
            query: query,
            forward_limit: forward_limit,
            reverse_limit: reverse_limit,
            classification: classification
          )

          forward_keys = TermsQuery.call(
            query: query,
            limit: forward_limit,
            field: "forward_#{classification}_shelfkey"
          )

          reverse_keys = TermsQuery.call(
            query: reverse_query,
            limit: reverse_limit,
            field: "reverse_#{classification}_shelfkey"
          )

          forward_call_numbers = list[:after].flatten.map(&:call_number)
          forward_sample = forward_call_numbers.uniq.map do |call_number|
            ShelfKey.forward(call_number)
          end

          reverse_call_numbers = list[:before].flatten.map(&:call_number)
          reverse_sample = reverse_call_numbers.uniq.map do |call_number|
            ShelfKey.reverse(call_number)
          end

          expect(forward_keys).to eq(forward_sample)
          expect(reverse_keys).to eq(reverse_sample)
        end
      end
    end
  end
end
