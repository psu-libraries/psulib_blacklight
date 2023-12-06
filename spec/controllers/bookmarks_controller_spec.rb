# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookmarksController, type: :controller do
  describe 'GET #bulk_ris' do
    let(:mock_bookmarks) { instance_double(Blacklight::Bookmarks) }
    let(:expected_content_type) { 'application/x-research-info-systems' }
    let(:expected_file_name) { 'document.ris' }

    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @request.headers[Settings.user_header] = 'user1234@psu.edu'
      @request.headers[Settings.groups_header] = Settings.admin_group
      user = User.new(email: 'user1234@psu.edu')
      sign_in user
      allow(controller).to receive(:action_documents).and_return(
        [{
          'response' =>
          { 'docs' =>
              [{ 'id' => '38685872' },
               { 'id' => '24053587' },
               { 'id' => '20049333' }] }
        }]
      )
    end

    it 'sends the RIS file' do
      get :bulk_ris

      expect(response.headers['Content-Disposition']).to include("attachment; filename=\"#{expected_file_name}\"")
      expect(response.headers['Content-Type']).to eq(expected_content_type)
      expect(response.body).to match(/Becoming/)
    end
  end
end
