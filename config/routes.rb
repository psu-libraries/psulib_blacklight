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
    concerns [:searchable, :range_searchable]
  end

  resource :bento, controller: :bento, defaults: { format: :json }, only: [:index], as: 'bento', path: '/bento' do
    concerns :searchable
  end

  resources :sitemap, defaults: { format: :xml }, only: [:index, :show]

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns [:exportable, :marc_viewable]
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  resources :etas, only: [:show]

  devise_for :users

  match '/catalog/:id/report_issue' => 'catalog#report_issue', via: [:get, :post], as: 'report_issue_solr_document'

  get '/browse', controller: :browse, action: :index

  namespace :availability do
    get '/sirsi-data', to: 'availability#sirsi_data'
    get '/sirsi-item-data', to: 'availability#sirsi_item_data'
  end

  # error pages
  match '/404' => 'errors#not_found', via: :all
  match '/422' => 'errors#not_found', via: :all
  match '/500' => 'errors#internal_server_error', via: :all

  get 'catalog/:id', id: /\d+[.,;:!"')\]]?/, to: 'catalog#show'
  get 'catalog/:id/marc_view', to: 'catalog#librarian_view', as: 'marc_view'

  get '/about' => 'high_voltage/pages#show', id: 'about'
  get '/search_tips' => 'high_voltage/pages#show', id: 'search_tips'

  # catchall for not predefined requests - keep this at the very bottom of the routes file
  match '*catch_unknown_routes' => 'errors#not_found', via: :all
end
