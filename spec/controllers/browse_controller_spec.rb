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

  describe 'GET #authors' do
    subject { response }

    before { get :authors }

    it { is_expected.to be_successful }

    it 'builds a author list' do
      expect(assigns(:author_list)).to be_a(BrowseList)
    end
  end

  describe 'GET #subjects' do
    subject { response }

    before { get :subjects }

    it { is_expected.to be_successful }

    it 'builds a subject list' do
      expect(assigns(:subject_list)).to be_a(BrowseList)
    end
  end

  describe 'GET #titles' do
    subject { response }

    before { get :titles }

    it { is_expected.to be_successful }

    it 'builds a title list' do
      expect(assigns(:title_list)).to be_a(BrowseList)
    end
  end
end
