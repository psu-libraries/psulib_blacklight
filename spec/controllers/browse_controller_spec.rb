# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrowseController, type: :controller do
  describe 'GET #index' do
    subject { response }

    before { get :index }

    it { is_expected.to be_successful }

    it 'builds a shelf list' do
      expect(assigns(:shelf_list)).to be_a(ShelfListPresenter)
    end
  end
end
