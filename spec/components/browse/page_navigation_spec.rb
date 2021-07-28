# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Browse::PageNavigation, type: :component do
  let(:node) { render_inline(described_class.new(prev_item: prev_item,
                                                 next_item: next_item,
                                                 length: length)) }
  let(:length) { 20 }

  context 'when the shelf list has no previous page' do
    let(:next_item) { SolrDocument.new({ call_number_ssm: ['abc'] }) }
    let(:prev_item) { nil }

    specify do
      expect(node).not_to have_link('Previous')
      expect(node).to have_link('Next', href: '/browse?length=20&starting=abc')
    end
  end

  context 'when the shelf list has no next page' do
    let(:prev_item) { SolrDocument.new({ call_number_ssm: ['def'] }) }
    let(:next_item) { nil }

    specify do
      expect(node).to have_link('Previous', href: '/browse?ending=def&length=20')
      expect(node).not_to have_link('Next')
    end
  end

  context 'when the shelf list has both a previous and a next page' do
    let(:prev_item) { SolrDocument.new({ call_number_ssm: ['abc'] }) }
    let(:next_item) { SolrDocument.new({ call_number_ssm: ['def'] }) }

    specify do
      expect(node).to have_link('Previous', href: '/browse?ending=abc&length=20')
      expect(node).to have_link('Next', href: '/browse?length=20&starting=def')
    end
  end

  context 'when the shelf list has neither a previous nor a next page' do
    let(:prev_item) { nil }
    let(:next_item) { nil }

    specify do
      expect(node).not_to have_link('Previous')
      expect(node).not_to have_link('Next')
    end
  end
end
