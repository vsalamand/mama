Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  authenticated :user, ->(user) { user.admin? } do
    mount Blazer::Engine, at: "blazer"
  end


  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # get 'suggest', to: 'actions#suggest'
      # get 'menus', to: 'actions#menus'
      get 'recommend', to: 'actions#recommend'
      get 'get_recommendations', to: 'actions#get_recommendations'
      get 'card', to: 'actions#card'
      get 'search', to: 'actions#search'
      get 'foodlist', to: 'actions#foodlist'
      get 'select', to: 'actions#select'
      get 'profile', to: 'actions#profile'
      get 'cart', to: 'actions#cart'
      get 'set_cart_size', to: 'actions#set_cart_size'
      get 'add_to_cart', to: 'actions#add_to_cart'
      get 'remove_from_cart', to: 'actions#remove_from_cart'
      get 'add_to_history', to: 'actions#add_to_history'
      get 'ban_recipe', to: 'actions#ban_recipe'
      get 'checkout', to: 'actions#checkout'
      get 'direct_checkout', to: 'actions#direct_checkout'
      get 'order', to: 'actions#order'
      get 'order_history', to: 'actions#order_history'
      get 'grocerylist', to: 'actions#grocerylist'
      get 'recipelist', to: 'actions#recipelist'
      get 'diets', to: 'actions#diets'
      get 'set_diet', to: 'actions#set_diet'
      get 'user_diet', to: 'actions#user_diet'
      get 'get_sender_ids', to: 'actions#get_sender_ids'
      get 'destroy_user', to: 'actions#destroy_user'
      get 'get_post', to: 'actions#get_post'
      get 'get_recipe', to: 'actions#get_recipe'
      get 'get_foods', to: 'actions#get_foods'
      get 'get_units', to: 'actions#get_units'
    end
  end

  # devise_for :users
  devise_for :users, controllers: {
      registrations: "registrations",
      sessions: 'users/sessions'
    }

  root to: 'pages#home'

  get 'confirmation', to: 'pages#confirmation'
  get 'dashboard', to: 'pages#dashboard'
  get 'pending', to: 'pages#pending'
  get 'unmatch_foods', to: 'pages#unmatch_foods'
  get 'unmatch_products', to: 'pages#unmatch_products'
  get 'verify_items', to: 'pages#verify_items'
  get 'verify_listitems', to: 'pages#verify_listitems'
  get 'verify_products', to: 'pages#verify_products'
  post 'import', to: 'pages#import'
  get 'products_search', to: 'pages#products_search'
  get 'thank_you', to: "pages#thank_you"

  get 'profile', to: 'pages#profile'


  resources :recipes do
    collection do
      get 'import', to: 'recipes#import'
      get 'search', to: 'recipes#search'
    end
    member do
      get 'card', to: "recipes#card"
      get :set_published_status
      get :set_dismissed_status
      get :cart
      get :god_show
      get :add_to_list
    end
    resources :items do
      get :add_to_list
    end
  end

  resources :lists do
    get 'fetch_suggested_items', to: "lists#fetch_suggested_items"
    get 'fetch_price', to: "lists#fetch_price"
    get 'get_cart', to: "lists#get_cart"
    post 'share', to: "lists#share"
    post 'send_invite', to: "lists#send_invite"
    get 'accept_invite', to: "lists#accept_invite"
    resources :list_items, only: [ :create, :show, :destroy, :edit, :update ] do
      collection do
        patch :sort
      end
      get :complete
      get :uncomplete
      resources :items do
        get 'validate', to: "items#validate"
        get 'unvalidate', to: "items#unvalidate"
      end
      get 'report', to: "products#report"
      get 'search', to: "products#search"
    end
    resources :collaborations, only: [:create, :destroy]
  end

  resources :carts do
    post 'share', to: "carts#share"
    post 'special_share', to: "carts#special_share"
    get :fetch_price
    member do
      get 'search', to: "carts#search"
      get :add_to_cart
    end
    resources :cart_items, only: [:show, :destroy, :edit, :update] do
      get 'report', to: "products#report"
      get :search
    end
  end

  resources :recipe_lists
  resources :items
  resources :products
  resources :stores do
    resources :store_carts do
      get 'fetch_price', to: "store_carts#fetch_price"
      member do
        get :add_to_cart
      end
      resources :store_cart_items do
        get :search
        get :fetch_index
      end
    end
    get :catalog
    get :cart
  end

  resources :food_lists do
    member do
      get :add
      get 'fetch_recipes', to: "food_lists#fetch_recipes"
      get 'get_cart', to: "food_lists#get_cart"
    end
    resources :food_list_items
  end


  resources :food_list_items do
    member do
      get :create_foodlist_item
    end
  end


  resources :recommendations  do
    resources :recommendation_items
    member do
      get :publish
    end
  end

  resources :meta_recipes do
    resources :meta_recipe_items
  end

  resources :meta_recipe_lists do
    get 'pool', to: 'meta_recipe_lists#pool'
    collection do
      get :pending
    end
    member do
      get :create_recipe
    end
    resources :meta_recipe_list_items
  end

  # Sidekiq Web UI, only for admins.
  require "sidekiq/web"
  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
