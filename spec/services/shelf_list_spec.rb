# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShelfList do
  before(:all) do
    CatalogFactory.load_call_numbers
  end

  after(:all) do
    CatalogFactory.load_defaults
  end

  let(:natural_sort) do
    Blacklight
      .default_index
      .connection
      .get('select', params: { q: '*:*', fl: ['call_number_ssm'], start: 0, rows: 1000000 })
      .dig('response', 'docs')
      .map { |doc| doc['call_number_ssm'] }
      .flatten
      .sort do |first, second|
        described_class.generate_forward_shelfkey(first) <=> described_class.generate_forward_shelfkey(second)
      end
  end

  # @note This is more of a "sanity check" to verify that the sort order of both our forward and reverse shelf keys
  # match up with reality.
  context 'when retrieving the entire list of call numbers' do
    it 'has the same forward order as it does when it is sorted naturally' do
      forward_sort = described_class
        .call(query: '0', forward_limit: 1000, reverse_limit: 0)[:after]
        .map(&:call_number)

      expect(natural_sort).to eq(forward_sort)
    end

    it 'has the same REVERSE order as it does when it is sorted naturally' do
      reverse_sort = described_class
        .call(query: 'ZZ999.999 .Z999 9999', forward_limit: 0, reverse_limit: 1000)[:before]
        .map(&:call_number)

      expect(natural_sort.reverse).to eq(reverse_sort)
    end
  end

  # @note This performs a set of randomized queries against the existing call numnbers, much like a user would in real
  # life. The results should match the same order at the natural listing of all call numbers.
  context 'when retrieving different segments of call numbers' do
    let(:queries) { ('A'..'Z').to_a }
    let(:limits) { (0..7).to_a }

    it 'has the same order as the natural listing' do
      failed = false

      100.times do
        params = {
          query: queries.sample,
          forward_limit: limits.sample,
          reverse_limit: limits.sample
        }

        test_set = described_class.call(params)
        combined_set = test_set[:before].map(&:call_number).reverse + test_set[:after].map(&:call_number)

        next if combined_set.empty?

        # Check to see if our combined backward + forward results exist in the same order as a listing of all the call
        # numbers.
        # rubocop:disable Performance/MethodObjectAsBlock
        if natural_sort.each_cons(combined_set.length).any?(&combined_set.method(:==))
          puts "    Passed: #{params.inspect}"
        else
          puts "    FAILED: #{params.inspect}"
          failed = true
        end
        # rubocop:enable Performance/MethodObjectAsBlock
      end

      expect(failed).to be(false)
    end
  end
end
