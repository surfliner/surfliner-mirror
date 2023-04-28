require "sidekiq/web"

Rails.application.routes.draw do
  mount Blacklight::Engine => "/"

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: "catalog", path: "/catalog", controller: "catalog" do
    concerns :searchable
  end

  # OmniAuth Google authentication for Devise
  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}
  devise_scope :user do
    get "/users/sign_in", to: "users/sessions#new", as: :new_user_session
    get "/users/sign_out", to: "users/sessions#destroy", as: :destroy_user_session
  end

  namespace :qa, path: "/authorities", as: :qa_schema do
    get "/terms/schema/:availability/:property", controller: :schema, action: :index
    get "/search/schema/:availability/:property", controller: :schema, action: :search
    get "/show/schema/:availability/:property/:id", controller: :schema, action: :show
    get "/fetch/schema/:availability/:property", controller: :schema, action: :fetch

    # CORS handling
    match "/terms/schema/:availability/:property", to: "application#options", via: [:options]
    match "/search/schema/:availability/:property", to: "application#options", via: [:options]
    match "/show/schema/:availability/:property/:id", to: "application#options", via: [:options]
    match "/fetch/schema/:availability/:property", to: "application#options", via: [:options]
  end
  mount Qa::Engine, at: "/authorities"

  mount Hyrax::Engine, at: "/"
  mount(Bulkrax::Engine, at: "/") if
    Rails.application.config.feature_bulkrax
  resources :welcome, only: "index"
  root "hyrax/homepage#index"
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new
  #
  # https://github.com/mperham/sidekiq/wiki/Monitoring#devise
  authenticate :user, lambda { |u| u.groups.include? "admin" } do
    mount Sidekiq::Web => "/sidekiq"
  end

  resources :solr_documents, only: [:show], path: "/catalog", controller: "catalog" do
    concerns :exportable
  end

  # allow derivative download
  get "downloads/:id/:use", controller: "hyrax/downloads", action: :show

  post "/dashboard/collections/:id/publish" => "hyrax/dashboard/collections#publish"
  put "/concern/generic_objects/:id/unpublish" => "hyrax/generic_objects#unpublish"
  put "/concern/generic_objects/:id/remove_member" => "hyrax/generic_objects#remove_member"

  resources :bookmarks do
    concerns :exportable

    collection do
      delete "clear"
    end
  end

  resource :collection, path: :dashboard_collection

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
