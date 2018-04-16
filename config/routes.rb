Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'suggest', to: 'actions#suggest'
      get 'menus', to: 'actions#menus'
      get 'search', to: 'actions#search'
      get 'select', to: 'actions#select'
      get 'recommend', to: 'actions#recommend'
      get 'profile', to: 'actions#profile'
      get 'cart', to: 'actions#cart'
      get 'add_to_cart', to: 'actions#add_to_cart'
      get 'remove_from_cart', to: 'actions#remove_from_cart'
      get 'checkout', to: 'actions#checkout'
      get 'order', to: 'actions#order'
      get 'order_history', to: 'actions#order_history'
      get 'grocerylist', to: 'actions#grocerylist'
      get 'recipelist', to: 'actions#recipelist'
    end
  end

  devise_for :users

  root to: 'pages#home'

  get 'confirmation', to: 'pages#confirmation'

  resources :recipes do
    collection do
      get 'pending', to: 'recipes#pending'
      get 'import', to: 'recipes#import'
      # get 'recipes', to: 'recipes#show'
    end
    member do
      get :set_published_status
      get :set_dismissed_status
    end
    resources :items
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
