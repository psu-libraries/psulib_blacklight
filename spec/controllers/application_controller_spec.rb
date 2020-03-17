# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let(:application_controller) { described_class.new }

  describe 'readonly?' do
    it 'returns true when readonly is set to true in blackcat_messages.yml' do
      allow(application_controller).to receive(:message_file?).and_return(true)
      allow(application_controller).to receive(:message_status).and_return(readonly: true)
      expect(application_controller.blackcat_message?(:readonly)).to be true
    end

    it 'readonly is set to false with blackcat_messages.yml' do
      allow(application_controller).to receive(:message_file?).and_return(true)
      allow(application_controller).to receive(:message_status).and_return(readonly: false)
      expect(application_controller.blackcat_message?(:readonly)).to be false
    end

    it 'readonly is set to false by default if blackcat_messages.yml does not exist' do
      allow(application_controller).to receive(:message_file?).and_return(false)
      expect(application_controller.blackcat_message?(:readonly)).to be false
    end

    it 'readonly is set to false if blackcat_messages.yml exists but readonly key is missing' do
      allow(application_controller).to receive(:message_file?).and_return(true)
      allow(application_controller).to receive(:message_status).and_return({})
      expect(application_controller.blackcat_message?(:readonly)).to be false
    end
  end

  describe 'alert message' do
    before do
      allow(application_controller).to receive(:blackcat_message).with(:alert).and_return('An F5 Sharknado is approaching the eastern seaboard, take cover.')
      allow(application_controller).to receive(:blackcat_message?).with(:alert).and_return(true)
    end

    it 'flashes the alert message when present in blackcat_messages.yml' do
      application_controller.send(:flash_alert)
      expect(flash[:error]).to match('An F5 Sharknado is approaching the eastern seaboard, take cover.')
    end
  end

  describe 'announcement_message' do
    it 'returns the announcement message when it is set in blackcat_messages.yml' do
      allow(application_controller).to receive(:message_file?).and_return(true)
      allow(application_controller).to receive(:message_status).and_return(announcement: 'Test message')
      expect(application_controller.blackcat_message(:announcement)).to eq 'Test message'
    end

    it 'falls back to blacklight.en.yml announcement if announcement not defined in blackcat_messages.yml' do
      allow(application_controller).to receive(:message_file?).and_return(true)
      allow(application_controller).to receive(:message_status).and_return({})
      expect(application_controller.blackcat_message(:announcement)).to eq I18n.t('blacklight.announcement.html')
    end

    it 'falls back to blacklight.en.yml announcement if blackcat_messages.yml does not exists' do
      allow(application_controller).to receive(:message_file?).and_return(false)
      expect(application_controller.blackcat_message(:announcement)).to eq I18n.t('blacklight.announcement.html')
    end
  end
end
