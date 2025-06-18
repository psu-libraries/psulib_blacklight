# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BentoController do
  describe '#index' do
    context 'when an html format request comes in' do
      it 'responds with unsupported media type' do
        get :index, params: { format: :html }

        expect(response).to have_http_status(:unsupported_media_type)
      end
    end

    context 'when it returns json' do
      render_views
      let(:json_response) { response.parsed_body }

      before do
        get :index, params: { format: :json, utf8: '✓', q: 'green', per_page: '3' }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'has the expected keys' do
        expect(json_response.keys).to match(['continueSearch', 'meta', 'data'])
      end

      it 'has a continue search link' do
        expect(json_response['continueSearch']).to include('http://test.host/catalog?q=green')
      end

      it 'has a meta key with metadata containing total count of results' do
        expect(json_response['meta']&.dig('pages', 'total_count')).to be(7)
      end

      it 'has a data key with 3 results' do
        expect(json_response['data'].count).to eq 3
      end
    end

    describe 'enforce_bot_challenge' do
      let(:whitelisted_ip) { '192.168.1.1' }
      let(:non_whitelisted_ip) { '10.0.0.1' }

      before do
        allow(BotChallengePage::BotChallengePageController)
          .to receive(:bot_challenge_enforce_filter)
        ENV['BOT_CHALLENGE_IP_WHITELIST'] = whitelisted_ip
      end

      after do
        ENV['BOT_CHALLENGE_IP_WHITELIST'] = nil
      end

      context 'when remote_ip is whitelisted' do
        it 'does not call bot_challenge_enforce_filter' do
          request.remote_addr = whitelisted_ip

          get :index
          expect(BotChallengePage::BotChallengePageController)
            .not_to have_received(:bot_challenge_enforce_filter)
        end
      end

      context 'when remote_ip is not whitelisted' do
        it 'calls bot_challenge_enforce_filter' do
          request.remote_addr = non_whitelisted_ip

          get :index
          expect(BotChallengePage::BotChallengePageController)
            .to have_received(:bot_challenge_enforce_filter)
            .with(instance_of(described_class), immediate: true)
        end
      end
    end
  end
end
