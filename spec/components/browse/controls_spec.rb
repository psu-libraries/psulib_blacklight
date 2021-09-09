# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Browse::Controls, type: :component do
  context 'when the paginator and navigator are not view components' do
    it 'renders an error' do
      expect {
        described_class.new(navigator: 'navigator', paginator: 'paginator')
      }.to raise_error(ArgumentError, 'navigator and paginator must be view components')
    end
  end

  context 'when no paginator is specified' do
    subject { described_class.new(navigator: navigator) }

    let(:navigator) { ViewComponent::Base.new }

    its(:paginator) { is_expected.to be_a(Browse::PageSizeSelector) }
    its(:navigator) { is_expected.to be_a(ViewComponent::Base) }
  end

  context 'when specifying both navigator and paginator' do
    subject { described_class.new(navigator: navigator, paginator: paginator) }

    let(:navigator) { ViewComponent::Base.new }
    let(:paginator) { ViewComponent::Base.new }

    its(:paginator) { is_expected.to be_a(ViewComponent::Base) }
    its(:navigator) { is_expected.to be_a(ViewComponent::Base) }
  end
end
