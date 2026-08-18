# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RIS file download' do
  let(:expected_content_type) { 'application/x-research-info-systems' }
  let(:expected_file_name) { 'document.ris' }

  it 'returns an RIS file with correct headers' do
    get '/catalog/22090269/ris'

    expect(response).to have_http_status(:success)
    expect(response.headers['Content-Disposition']).to include("attachment; filename=\"#{expected_file_name}\"")
    expect(response.headers['Content-Type']).to eq(expected_content_type)
  end
end
