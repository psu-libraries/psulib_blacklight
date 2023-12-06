# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookmarksController, type: :controller do
  describe 'GET #bulk_ris' do
    let(:mock_bookmarks) { instance_double(Blacklight::Bookmarks) }
    let(:expected_content_type) { 'application/x-research-info-systems' }
    let(:expected_file_name) { 'document.ris' }
    let(:user) { User.new(email: 'user1237@psu.edu') }
    let!(:bookmark1) { instance_double(Bookmark, document_id: '38685872') }
    let!(:bookmark2) { instance_double(Bookmark, document_id: '24053587') }
    let!(:bookmark3) { instance_double(Bookmark, document_id: '20049333') }
    let!(:bookmarks) { [bookmark1, bookmark2, bookmark3] }

    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @request.headers[Settings.user_header] = 'user1234@psu.edu'
      @request.headers[Settings.groups_header] = Settings.admin_group

      sign_in user

      allow(controller).to receive(:token_or_current_or_guest_user).and_return(user)
      allow(user).to receive(:bookmarks).and_return(bookmarks)
    end

    it 'sends the RIS file' do
      get :bulk_ris

      expect(response.headers['Content-Disposition']).to include("attachment; filename=\"#{expected_file_name}\"")
      expect(response.headers['Content-Type']).to eq(expected_content_type)
      expect(response.body).to match(/TI  - Becoming/)
      expect(response.body).to match(/TI  - Robot ethics/)
    end
  end
end
