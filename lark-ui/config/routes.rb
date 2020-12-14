Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resource :record, only: :show
  get '/search/:q', action: :search, controller: "search"

end
