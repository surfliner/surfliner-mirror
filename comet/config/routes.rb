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

  mount Qa::Engine => "/authorities"
  mount Hyrax::Engine, at: "/"
  resources :welcome, only: "index"
  root "hyrax/homepage#index"
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new
  #
  # https://github.com/mperham/sidekiq/wiki/Monitoring#devise
  authenticate :user, lambda { |u| u.superadmin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  resources :solr_documents, only: [:show], path: "/catalog", controller: "catalog" do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete "clear"
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
