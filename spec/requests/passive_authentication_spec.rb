# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Passive authentication' do
  let(:email) { 'user1234@psu.edu' }

  it 'logs in user automatically when header is present' do
    get '/', headers: {
      Settings.user_header => email
    }

    user = User.find_by(email: email)
    expect(user).to be_present
    expect(controller.current_user).to eq(user)
  end

  it 'does not log in user when header is missing' do
    get '/'

    expect(controller.current_user).to be_nil
  end
end
