# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShelfKey do
  describe '::normalized' do
    subject { described_class.normalized(number) }

    context 'with LC classification' do
      context 'with a proper LC number' do
        let(:number) { 'AB .Z1234 2010' }

        it { is_expected.to eq('AB..Z1234.2010') }
      end

      context 'when a bogus LC number' do
        let(:number) { 'This is not LC' }

        it { is_expected.to eq('THIS.IS.NOT.LC') }
      end
    end

    context 'with DEWEY classification' do
      context 'with a proper LC number' do
        let(:number) { 'AAA332.7P384' }

        it { is_expected.to eq('AAA03327.P384') }
      end

      context 'when a bogus DEWEY number' do
        let(:number) { 'AAAThis is not DEWEY' }

        it { is_expected.to eq('AAATHIS.IS.NOT.DEWEY') }
      end
    end
  end
end
