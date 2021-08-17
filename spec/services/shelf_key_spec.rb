# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShelfKey do
  describe '::forward' do
    subject { described_class.forward(number) }

    context 'with a proper LC number' do
      let(:number) { 'AB .Z1234 2010' }

      it { is_expected.to eq('AB..Z1234.2010') }
    end

    context 'when a bogus LC number' do
      let(:number) { 'This is not LC' }

      it { is_expected.to eq('THIS.IS.NOT.LC') }
    end
  end

  describe '::reverse' do
    subject { described_class.reverse(number) }

    context 'with a proper LC number' do
      let(:number) { 'AB .Z1234 2010' }

      it { is_expected.to eq('PO..0YXWV.XZYZ~') }
    end

    context 'when a bogus LC number' do
      let(:number) { 'This is not LC' }

      it { is_expected.to eq('6IH7.H7.CB6.EN~') }
    end
  end
end
