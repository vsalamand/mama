Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # get 'suggest', to: 'actions#suggest'
      # get 'menus', to: 'actions#menus'
      get 'recommend', to: 'actions#recommend'
      get 'card', to: 'actions#card'
      get 'search', to: 'actions#search'
      get 'select', to: 'actions#select'
      get 'profile', to: 'actions#profile'
      get 'cart', to: 'actions#cart'
      get 'add_to_cart', to: 'actions#add_to_cart'
      get 'remove_from_cart', to: 'actions#remove_from_cart'
      get 'add_to_history', to: 'actions#add_to_history'
      get 'ban_recipe', to: 'actions#ban_recipe'
      get 'checkout', to: 'actions#checkout'
      get 'order', to: 'actions#order'
      get 'order_history', to: 'actions#order_history'
      get 'grocerylist', to: 'actions#grocerylist'
      get 'recipelist', to: 'actions#recipelist'
      get 'diets', to: 'actions#diets'
      get 'set_diet', to: 'actions#set_diet'
      get 'user_diet', to: 'actions#user_diet'
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
      get 'card', to: "recipes#card"
      get :set_published_status
      get :set_dismissed_status
    end
    resources :items
  end

  # Sidekiq Web UI, only for admins.
  require "sidekiq/web"
  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
