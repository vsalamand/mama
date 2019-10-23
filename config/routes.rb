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


  get 'assistant', to: 'meta_recipe_lists#new'
  get 'seasonal', to: 'pages#seasonal'
  get 'uncategorized', to: 'pages#uncategorized'
  get 'veggie', to: 'pages#veggie'
  get 'salad', to: 'pages#salad'
  get 'pasta', to: 'pages#pasta'
  get 'potato', to: 'pages#potato'
  get 'meat', to: 'pages#meat'
  get 'fish', to: 'pages#fish'
  get 'egg', to: 'pages#egg'
  get 'snack', to: 'pages#snack'
  get 'burger', to: 'pages#burger'
  get 'pizza', to: 'pages#pizza'

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
    end
    resources :items

  end

  resources :lists, only: [ :show, :destroy ] do
    get 'fetch_recipes', to: "lists#fetch_recipes"
    get 'get_cart', to: "lists#get_cart"
    resources :list_items, only: [ :create, :show, :destroy, :edit, :update ] do
      resources :items do
        get 'validate', to: "items#validate"
        get 'unvalidate', to: "items#unvalidate"
      end
      get 'report', to: "products#report"
      get 'search', to: "products#search"
    end
  end

  resources :carts do
    resources :cart_items, only: [:show, :destroy, :edit, :update] do
      get 'report', to: "products#report"
      get 'search', to: "products#search"
    end
  end

  resources :recipe_lists
  resources :items


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
