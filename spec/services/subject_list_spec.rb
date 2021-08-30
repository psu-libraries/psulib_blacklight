# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubjectList do
  describe '#empty?' do
    it { is_expected.to delegate_method(:empty?).to :entries }
  end

  context 'with no provided params' do
    subject(:list) { described_class.new }

    it { is_expected.not_to be_last_page }

    specify do
      expect(list.entries.first.value).to eq('Acetaldehyde—Germany')
      expect(list.entries.first.hits).to eq(1)
      expect(list.entries.last.value).to eq('African Americans—Southern States')
      expect(list.entries.last.hits).to eq(1)
      expect(list.entries.count).to eq(10)
    end
  end

  context 'when starting a the second page' do
    subject(:list) { described_class.new(page: 2) }

    it { is_expected.not_to be_last_page }

    specify do
      expect(list.entries.first.value).to eq('Aggada')
      expect(list.entries.first.hits).to eq(1)
      expect(list.entries.last.value).to eq('Analog-to-digital converters—Standards')
      expect(list.entries.last.hits).to eq(1)
      expect(list.entries.count).to eq(10)
    end
  end

  context 'when requesting more items per page' do
    subject(:list) { described_class.new(length: 20) }

    it { is_expected.not_to be_last_page }

    specify do
      expect(list.entries[0].value).to eq('Acetaldehyde—Germany')
      expect(list.entries[0].hits).to eq(1)
      expect(list.entries[9].value).to eq('African Americans—Southern States')
      expect(list.entries[9].hits).to eq(1)
      expect(list.entries[10].value).to eq('Aggada')
      expect(list.entries[10].hits).to eq(1)
      expect(list.entries[19].value).to eq('Analog-to-digital converters—Standards')
      expect(list.entries[19].hits).to eq(1)
      expect(list.entries.count).to eq(20)
    end
  end

  context 'when this is the last page' do
    subject(:list) { described_class.new(page: 15, length: 50) }

    it { is_expected.to be_last_page }

    specify do
      expect(list.entries.first.value).to eq('Women in war—Juvenile fiction')
      expect(list.entries.first.hits).to eq(1)
      expect(list.entries.count).to eq(37)
    end
  end

  context 'when specifying a prefix' do
    subject(:list) { described_class.new(prefix: 'M') }

    it { is_expected.not_to be_last_page }

    specify do
      expect(list.entries.first.value).to eq('Magic—Fiction')
      expect(list.entries.first.hits).to eq(1)
      expect(list.entries.last.value).to eq('Married people—Drama')
      expect(list.entries.last.hits).to eq(1)
      expect(list.entries.count).to eq(10)
    end
  end
end
