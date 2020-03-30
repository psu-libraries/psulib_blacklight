# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Blackcat Messages', type: :request do
  before do
    allow(YAML).to receive(:load_file).and_call_original
    allow(YAML).to receive(:load_file)
      .with(Rails.root.join('config', 'blackcat_messages.yml'))
      .and_return(YAML.safe_load(config))
  end

  let (:config) { '' }

  describe 'alert message' do
    context 'when there is a value present for the "alert" key' do
      let (:config) { 'alert: stubbed alert' }

      it 'flashes the alert message when present in blackcat_messages.yml' do
        skip('Test passes locally but not on Travis.') if ENV['TRAVIS']
        get root_path

        expect(flash[:error]).to match 'stubbed alert'
      end
    end

    context 'when there is not a value present for the "alert" key' do
      it 'does not flashes an alert message' do
        skip('Test passes locally but not on Travis.') if ENV['TRAVIS']
        get root_path

        expect(flash[:error]).not_to match 'stubbed alert'
      end
    end
  end

  describe 'announcement message' do
    context 'when there is a value present for the "announcement" key in blackcat_messages.yml' do
      let (:config) { 'announcement: stubbed announcement' }

      it 'display the announcement message' do
        skip('Test passes locally but not on Travis.') if ENV['TRAVIS']
        get root_path

        expect(response.body).to include 'stubbed announcement'
      end
    end

    context 'when there is not a value present for the "announcement" key in blackcat_messages.yml' do
      it 'falls back to blacklight.en.yml announcement' do
        skip('Test passes locally but not on Travis.') if ENV['TRAVIS']
        get root_path

        expect(response.body).to match I18n.t('blacklight.announcement.html')
      end
    end
  end
end
