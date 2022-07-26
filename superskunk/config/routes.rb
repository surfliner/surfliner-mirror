Rails.application.routes.draw do
  resources :resources, only: [:show]

  get "/acls", controller: "acls", action: :show
end
