# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrowseController, type: :controller do
  describe 'GET #call_numbers' do
    subject { response }

    before { get :call_numbers, params: { classification: classification } }

    context 'when Browse by LC Call Number' do
      let(:classification) { 'lc' }

      it { is_expected.to be_successful }

      it 'builds an lc shelf list' do
        expect(assigns(:shelf_list)).to be_a(ShelfListPresenter)
        expect(assigns(:shelf_list).classification).to eq 'lc'
      end
    end

    context 'when Browse by DEWEY Call Number' do
      let(:classification) { 'dewey' }

      it { is_expected.to be_successful }

      it 'builds a dewey shelf list' do
        expect(assigns(:shelf_list)).to be_a(ShelfListPresenter)
        expect(assigns(:shelf_list).classification).to eq 'dewey'
      end
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
