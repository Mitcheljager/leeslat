Rails.application.routes.draw do
  concern :paginatable do
    get '(pagina/:page)', action: :index, on: :collection, as: ''
  end

  root "books#index"

  get "up", to: "rails/health#show", as: :rails_health_check
  get "zoeken/:query", to: "search#index"

  resources :sources, param: :slug
  resources :genres, param: :slug
  resources :listings, concerns: :paginatable
  resources :authors, concerns: :paginatable
  resources :books, param: :slug_and_isbn, path: "boek", except: [:index], concerns: :paginatable
end
