Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'suggest', to: 'actions#suggest'
      get 'search', to: 'actions#search'
      get 'select', to: 'actions#select'
      get 'recommend', to: 'actions#recommend'
      get 'profile', to: 'actions#profile'
      get 'cart', to: 'actions#cart'
      get 'add_to_cart', to: 'actions#add_to_cart'
      get 'remove_from_cart', to: 'actions#remove_from_cart'
      get 'place_order', to: 'actions#place_order'
    end
  end

  devise_for :users

  root to: 'pages#home'

  get 'confirmation', to: 'pages#confirmation'

  resources :recipes do
    collection do
      get 'pending', to: 'recipes#pending'
      get 'import', to: 'recipes#import'
    end
    member do
      get :set_published_status
      get :set_dismissed_status
    end
    resources :items
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
