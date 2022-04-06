# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController do
  context 'when given the right headers' do
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @request.headers[Settings.user_header] = 'user1234@psu.edu'
      @request.headers[Settings.groups_header] = Settings.admin_group
      user = User.new(email: 'user1234@psu.edu')
      sign_in user
    end

    it 'sets the group' do
      get :login
      expect(session[:groups]).to include(Settings.admin_group)
    end

    it 'redirects to index' do
      get :login
      expect(response).to redirect_to('/')
    end

    it 'redirects to home' do
      @request.env['ORIGINAL_FULLPATH'] = '/home'
      get :login
      expect(response).to redirect_to('/home')
    end
  end

  context 'when given the wrong headers' do
    before do
      user = User.new(email: 'user1234@psu.edu')
      sign_in user
    end

    it 'does not set a the group' do
      get :login
      expect(session[:groups]).to eq([])
    end

    it 'redirects to login' do
      get :login
      expect(response).to redirect_to('/login')
    end
  end

  describe '#authorize_profiler' do
    before do
      allow(Rack::MiniProfiler).to receive(:authorize_request)
    end

    context 'when signed in as admin' do
      before do
        request.session[:groups] = [Settings.admin_group]
      end

      specify do
        controller.send(:authorize_profiler)
        expect(Rack::MiniProfiler).to have_received(:authorize_request)
      end
    end

    context 'when not signed in' do
      before do
        request.session[:groups] = []
      end

      specify do
        controller.send(:authorize_profiler)
        expect(Rack::MiniProfiler).not_to have_received(:authorize_request)
      end
    end
  end
end
