# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Browse::FacetNavigation, type: :component do
  subject(:node) { render_inline(described_class.new(list: browse_list)) }

  let(:entry) { BrowseList::Entry.new('field-heading', '3') }

  describe 'the first page' do
    let(:browse_list) { instance_spy(BrowseList, page: 1, length: 10, entries: [entry]) }

    before do
      allow(browse_list).to receive(:last_page?).and_return(false)
      allow_any_instance_of(described_class).to receive(:params).and_return({ action: 'authors' })
    end

    context 'when browsing authors' do
      it { is_expected.to have_no_link('Previous') }
      it { is_expected.to have_link('Next', href: '/browse/authors?length=10&page=2') }
    end

    context 'when browsing subjects' do
      before { allow_any_instance_of(described_class).to receive(:params).and_return({ action: 'subjects' }) }

      it { is_expected.to have_no_link('Previous') }
      it { is_expected.to have_link('Next', href: '/browse/subjects?length=10&page=2') }
    end
  end

  describe 'the last page' do
    let(:browse_list) { instance_spy(BrowseList, page: 5, length: 10, entries: [entry]) }

    context 'when browsing authors' do
      before do
        allow_any_instance_of(described_class).to receive(:params).and_return({ action: 'authors' })
      end

      it { is_expected.to have_link('Previous', href: '/browse/authors?length=10&page=4') }
      it { is_expected.to have_no_link('Next') }
    end

    context 'when browsing subjects' do
      before do
        allow_any_instance_of(described_class).to receive(:params).and_return({ action: 'subjects' })
      end

      it { is_expected.to have_link('Previous', href: '/browse/subjects?length=10&page=4') }
      it { is_expected.to have_no_link('Next') }
    end
  end

  describe 'the middle' do
    let(:browse_list) { instance_spy(BrowseList, page: 3, length: 10, entries: [entry]) }

    before do
      allow(browse_list).to receive(:last_page?).and_return(false)
      allow_any_instance_of(described_class).to receive(:params).and_return({ action: 'subjects' })
    end

    context 'when browsing authors' do
      before { allow_any_instance_of(described_class).to receive(:params).and_return({ action: 'authors' }) }

      it { is_expected.to have_link('Previous', href: '/browse/authors?length=10&page=2') }
      it { is_expected.to have_link('Next', href: '/browse/authors?length=10&page=4') }
    end

    context 'when browsing subjects' do
      before { allow_any_instance_of(described_class).to receive(:params).and_return({ action: 'subjects' }) }

      it { is_expected.to have_link('Previous', href: '/browse/subjects?length=10&page=2') }
      it { is_expected.to have_link('Next', href: '/browse/subjects?length=10&page=4') }
    end
  end
end
