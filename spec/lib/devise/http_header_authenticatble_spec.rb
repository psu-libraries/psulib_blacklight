# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Devise::Strategies::HttpHeaderAuthenticatable do
  let(:strategy) { described_class.new(headers) }

  def authenticate!
    strategy.authenticate!
  end

  context 'when given an id' do
    let(:user_id) { 'djb44' }
    let(:headers) { { Settings.user_header => user_id } }

    it 'succeeds when given an header' do
      authenticate!
      expect(strategy).to be_successful
    end
  end

  context 'when given no header' do
    let(:headers) { {} }

    it 'fails' do
      authenticate!
      expect(strategy.successful?).to be false
    end
  end
end
