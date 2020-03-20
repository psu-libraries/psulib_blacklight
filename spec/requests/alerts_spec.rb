# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Errors', type: :request do
  describe 'alert message' do
    let(:file) { Tempfile.new('blackcat_messages.yml') }

    context 'when there is a value present for the "alert" key' do
      before do
        file.write('alert: stubbed alert')
        file.open
        allow(YAML).to receive(:load_file).and_call_original
        allow(YAML).to receive(:load_file)
          .with(Rails.root.join('config', 'blackcat_messages.yml'))
          .and_return(file.read)
      end

      it 'flashes the alert message when present in blackcat_messages.yml' do
        get root_path
        expect(flash[:error]).to match('stubbed alert')
      end
    end
  end
end
