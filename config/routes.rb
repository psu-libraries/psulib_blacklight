# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'catalog#index'

  # concerns
  concern :searchable, Blacklight::Routes::Searchable.new
  concern :exportable, Blacklight::Routes::Exportable.new
  concern :marc_viewable, Blacklight::Marc::Routes::MarcViewable.new
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new

  # mounts
  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  # resource and resources
  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns [:exportable, :marc_viewable]
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  devise_for :users

  # error pages
  match '/404' => 'errors#not_found', via: :all
  match '/422' => 'errors#not_found', via: :all
  match '/500' => 'errors#internal_server_error', via: :all
  get '/available/:titleID', to: redirect(Proc.new do |params|
    catkeys = []
    params[:titleID].split(',').each do |catkey|
      catkeys << "&titleID=#{catkey}"
    end

    "#{Rails.application.credentials.dig(:sirsi_url)}#{catkeys.join()}"
  end)
  get 'catalog/:id/marc_view', to: 'catalog#librarian_view', as: 'marc_view'
end
