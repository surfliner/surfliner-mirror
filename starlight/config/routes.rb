# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  mount Blacklight::Oembed::Engine, at: "oembed"
  mount Riiif::Engine => "/images", as: "riiif"
  root to: "spotlight/exhibits#index"
  mount Spotlight::Engine, at: "spotlight"
  mount Blacklight::Engine => "/"

  # https://github.com/mperham/sidekiq/wiki/Monitoring#devise
  authenticate :user, lambda { |u| u.superadmin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  #  root to: "catalog#index" # replaced by spotlight root path
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: "catalog", path: "/catalog", controller: "catalog" do
    concerns :searchable
  end

  if ENV["DATABASE_AUTH"]
    devise_for :users
  else
    devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
    devise_scope :user do
      get "/users/sign_in", to: "users/sessions#new", as: :new_user_session
      get "/users/sign_out", to: "users/sessions#destroy", as: :destroy_user_session
    end
  end

  concern :exportable, Blacklight::Routes::Exportable.new

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
