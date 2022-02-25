Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  match "oai", to: "oai#index", via: [:get, :post]
  match "item", to: "item#index", via: [:get]
end
