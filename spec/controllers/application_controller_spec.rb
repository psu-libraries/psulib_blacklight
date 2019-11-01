# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'readonly?' do
    let(:application_controller) { described_class.new }

    it 'returns true when readonly is set to true in read_only.yml' do
      allow(application_controller).to receive(:readonly_file?).and_return(true)
      allow(application_controller).to receive(:readonly_status).and_return(readonly: true)
      expect(application_controller.readonly?).to be true
    end

    it 'readonly is set to false with read_only.yml' do
      allow(application_controller).to receive(:readonly_file?).and_return(true)
      allow(application_controller).to receive(:readonly_status).and_return(readonly: false)
      expect(application_controller.readonly?).to be false
    end

    it 'readonly is set to false by default if read_only.yml does not exists' do
      allow(application_controller).to receive(:readonly_file?).and_return(false)
      expect(application_controller.readonly?).to be false
    end

    it 'readonly is set to false if read_only.yml exists but read_only key is missing' do
      allow(application_controller).to receive(:readonly_file?).and_return(true)
      allow(application_controller).to receive(:readonly_status).and_return({})
      expect(application_controller.readonly?).to be false
    end
  end
end
