# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Browse::SubjectNavigation, type: :component do
  let(:node) { render_inline(described_class.new(list: subject_list)) }
  let(:entry) { SubjectList::Entry.new('subject-heading', '3') }

  context 'when on the first page' do
    let(:subject_list) { instance_spy('SubjectList', page: 1, length: 10, entries: [entry]) }

    before do
      allow(subject_list).to receive(:last_page?).and_return(false)
    end

    specify do
      expect(node).not_to have_link('Previous')
      expect(node).to have_link('Next', href: '/browse/subjects?length=10&page=2')
    end
  end

  context 'when on the last page' do
    let(:subject_list) { instance_spy('SubjectList', page: 5, length: 10, entries: [entry]) }

    before do
      allow(subject_list).to receive(:last_page?).and_return(true)
    end

    specify do
      expect(node).to have_link('Previous', href: '/browse/subjects?length=10&page=4')
      expect(node).not_to have_link('Next')
    end
  end

  context 'when somewhere in the middle' do
    let(:subject_list) { instance_spy('SubjectList', page: 3, length: 10, entries: [entry]) }

    before do
      allow(subject_list).to receive(:last_page?).and_return(false)
    end

    specify do
      expect(node).to have_link('Previous', href: '/browse/subjects?length=10&page=2')
      expect(node).to have_link('Next', href: '/browse/subjects?length=10&page=4')
    end
  end
end
