# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe '#flash_alert' do
    it 'when ENV[\'alert\'] is present' do
      ENV['alert'] = 'Problems!'
      expect(controller.send(:flash_alert)).to eq 'Problems!'
    end

    it 'when ENV[\'alert\'] is not present' do
      ENV['alert'] = nil
      expect(controller.send(:flash_alert)).to be_nil
    end
  end
end
