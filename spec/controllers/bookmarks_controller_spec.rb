# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookmarksController do
  describe 'GET #bulk_ris' do
    let(:expected_content_type) { 'application/x-research-info-systems' }
    let(:expected_file_name) { 'document.ris' }
    let(:user) { User.new(email: 'user1237@psu.edu') }

    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @request.headers[Settings.user_header] = 'user1234@psu.edu'
      @request.headers[Settings.groups_header] = Settings.admin_group

      sign_in user
    end

    it 'sends the RIS file' do
      get :bulk_ris, params: { item_ids: '38685872,24053587' }

      expect(response.headers['Content-Disposition']).to include("attachment; filename=\"#{expected_file_name}\"")
      expect(response.headers['Content-Type']).to eq(expected_content_type)
      expect(response.body).to match(/TI  - Becoming/)
      expect(response.body).to match(/TI  - Robot ethics/)
    end
  end
end
