Rails.application.routes.draw do
  resources :resources, only: [:show]
end
