Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'suggest', to: 'actions#suggest'
      get 'search', to: 'actions#search'
    end
  end

  devise_for :users

  root to: 'pages#home'

  get 'search', to: 'pages#search'
  get 'suggest', to: 'pages#suggest'

  resources :recipes, only: [:show]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
