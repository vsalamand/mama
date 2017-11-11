Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'suggest', to: 'actions#suggest'
      get 'search', to: 'actions#search'
      get 'select', to: 'actions#select'
    end
  end

  devise_for :users

  root to: 'pages#home'

  get 'confirmation', to: 'pages#confirmation'

  resources :recipes do
    collection do
      get 'pending', to: 'recipes#pending'
    end
    resources :items
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
