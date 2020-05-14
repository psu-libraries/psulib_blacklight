# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EtasController, type: :controller do
  describe '#show' do
    before do
      json = file_fixture('21383783.json').read
      stub_request(:get, 'https://catalog.hathitrust.org/api/volumes/brief/oclc/21383783.json')
        .to_return(status: 200, body: json, headers: {})
    end
    it 'will render a link to HathiTrust ETAS' do
      get :show, params: { id: '21383783' }

      expect(response.body).to render_template('hathitrust/etas')
    end
  end
end
