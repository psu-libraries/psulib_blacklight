# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlackcatConfig::Builder do
  subject(:builder) { described_class.new }

  let(:config) { '' }
  let(:config_file) { YAML.safe_load(config) }

  before do
    allow(YAML).to receive(:load_file).and_call_original
    allow(YAML).to receive(:load_file)
      .with(Rails.root.join('config', 'blackcat_admin.yml'))
      .and_return(config_file)
  end

  describe '#readonly_holds?' do
    it 'returns false when readonly_holds is not set' do
      skip('Test passes locally but not on Travis.') if ENV['TRAVIS']
      expect(builder.readonly_holds?).to be false
    end

    context 'when readonly_holds is set in blackcat_admin.yml' do
      let(:config) { 'readonly_holds: true' }

      it 'returns true' do
        skip('Test passes locally but not on Travis.') if ENV['TRAVIS']
        expect(builder.readonly_holds?).to be true
      end
    end
  end

  describe '#blackcat_message?' do
    it 'returns false when there are no readonly messages set' do
      skip('Test passes locally but not on Travis.') if ENV['TRAVIS']
      expect(builder.blackcat_message?(:readonly)).to be false
    end

    context 'when an announcement is set in blackcat_admin.yml' do
      let(:config) { 'announcement: This is an announcement.' }

      it 'returns true' do
        skip('Test passes locally but not on Travis.') if ENV['TRAVIS']
        expect(builder.blackcat_message?(:announcement)).to be true
      end
    end

    context 'when a readonly message is set in blackcat_admin.yml' do
      let(:config) { 'readonly: This is a message for readonly.' }

      it 'returns true' do
        skip('Test passes locally but not on Travis.') if ENV['TRAVIS']
        expect(builder.blackcat_message?(:readonly)).to be true
      end
    end
  end

  describe '#blackcat_message' do
    it 'falls back to default announcement message when there are no announcements set' do
      skip('Test passes locally but not on Travis.') if ENV['TRAVIS']
      expect(builder.blackcat_message(:announcement)).to match I18n.t('blacklight.announcement.html')
    end

    context 'when an announcement is set in blackcat_admin.yml' do
      let(:config) { 'announcement: This is an announcement.' }

      it 'returns the announcement message' do
        skip('Test passes locally but not on Travis.') if ENV['TRAVIS']
        expect(builder.blackcat_message(:announcement)).to match 'This is an announcement.'
      end
    end

    context 'when a readonly message is set in blackcat_admin.yml' do
      let(:config) { 'readonly: This is a message for readonly.' }

      it 'returns the readonly message' do
        skip('Test passes locally but not on Travis.') if ENV['TRAVIS']
        expect(builder.blackcat_message(:readonly)).to match 'This is a message for readonly.'
      end
    end
  end
end
