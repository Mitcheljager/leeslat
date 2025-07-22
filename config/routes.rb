require "sidekiq/web"

Rails.application.routes.draw do
  concern :paginatable do
    get "(pagina/:page)", action: :index, on: :collection, as: ""
  end

  root "books#index"

  get "up", to: "rails/health#show", as: :rails_health_check
  mount Sidekiq::Web => "/sidekiq"

  # User and session
  resources :users, except: [:new]
  resources :sessions, only: [:create, :destroy]

  get "register", to: "users#new", as: "new_user"
  get "login", to: "sessions#new", as: "login"
  get "logout", to: "sessions#destroy", as: "logout"

  # Books and related
  resources :sources, param: :slug
  resources :genres, param: :slug
  resources :authors, concerns: :paginatable
  resources :books, param: :slug_and_isbn, path: "boek", only: [:show], concerns: :paginatable

  # Search
  post "zoeken", to: "search#post", as: :search_post
  get "zoeken/(:query)", to: "search#index", as: :search

  # Actions
  get "actions/index_by_isbn/:isbn", to: "actions#index_by_isbn"
  post "actions/attach_image_for_isbn", to: "actions#attach_image_for_isbn", as: :attach_image_for_isbn
  post "actions/run_all_scrapers_for_isbn", to: "actions#run_all_scrapers_for_isbn", as: :run_all_scrapers_for_isbn
  post "actions/generate_ai_description_for_isbn", to: "actions#generate_ai_description_for_isbn", as: :generate_ai_description_for_isbn
  post "actions/generate_ai_keywords_for_isbn", to: "actions#generate_ai_keywords_for_isbn", as: :generate_ai_keywords_for_isbn

  namespace :admin do
    get "/", to: "base#index", as: :root

    resources :books, param: :slug_and_isbn, concerns: :paginatable
    resources :listings, concerns: :paginatable
  end
end
