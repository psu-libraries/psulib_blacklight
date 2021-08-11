# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController do
  describe '#authorize_profiler' do
    before do
      allow(Rack::MiniProfiler).to receive(:authorize_request)
    end

    context 'when the matomo ID is not 7' do
      specify do
        expect(Settings.matomo_id).not_to eq(7)
        controller.send(:authorize_profiler)
        expect(Rack::MiniProfiler).to have_received(:authorize_request)
      end
    end

    context 'when the matomo ID is 7' do
      specify do
        current = Settings.matomo_id
        Settings.matomo_id = 7
        controller.send(:authorize_profiler)
        expect(Rack::MiniProfiler).not_to have_received(:authorize_request)
        Settings.matomo_id = current
      end
    end
  end
end
