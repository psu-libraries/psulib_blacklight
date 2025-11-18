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
  mount OkComputer::Engine, at: '/health'

  authenticate :user do
    get '/login', to: 'application#login', as: :login
  end

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
      get 'initialize_bookmark'
      delete 'clear'
      match 'bulk_ris/:item_ids', to: 'bookmarks#bulk_ris', via: [:get, :post], as: 'bulk_ris'
    end
  end

  resources :etas, only: [:show]

  devise_for :users

  match '/catalog/:id/report_issue' => 'catalog#report_issue', via: [:get, :post], as: 'report_issue_solr_document'
  match '/catalog/:id/ris' => 'catalog#ris', via: [:get, :post], as: 'ris_solr_document'

  resource :browse, controller: :browse, only: [] do
    get 'call_numbers', as: 'call_number'
    get 'authors', as: 'author'
    get 'subjects', as: 'subject'
    get 'titles', as: 'title'
  end

  namespace :availability do
    get '/sirsi-data', to: 'availability#sirsi_data'
    get '/sirsi-item-data', to: 'availability#sirsi_item_data'
  end

  namespace :links do
    get '/google-preview-data', to: 'google_preview#data'
    get '/hathi-link', to: 'hathi_link#data'
  end

  # error pages
  match '/404' => 'errors#not_found', via: :all
  match '/422' => 'errors#not_found', via: :all
  match '/500' => 'errors#internal_server_error', via: :all

  get 'catalog/:id', id: /\d+[.,;:!"')\]]?/, to: 'catalog#show'
  get 'catalog/:id/marc_view', to: 'catalog#librarian_view', as: 'marc_view'

  get '/about' => 'high_voltage/pages#show', id: 'about'
  get '/search_tips' => 'high_voltage/pages#show', id: 'search_tips'

  # Bot challenge page
  # post '/challenge', to: 'bot_challenge_page/bot_challenge_page#verify_challenge', as: :bot_detect_challenge

  # catchall for not predefined requests - keep this at the very bottom of the routes file
  match '*catch_unknown_routes' => 'errors#not_found', via: :all
end
