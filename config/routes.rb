Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  root to: 'pages#home'
  get 'search', to: 'pages#search'

  resources :recipes, only: [:show]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
