Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  authenticated :user, ->(user) { user.admin? } do
    mount Blazer::Engine, at: "blazer"
  end

  # mount ActionCable.server => '/cable'


  # PWA
  get '/service-worker.js', to: 'service_workers/workers#index'
  get '/manifest.json', to: 'service_workers/manifests#index'

  # API
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
      get 'get_store_section_items', to: 'actions#get_store_section_items'
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
  get 'duplicated_list_items', to: 'pages#duplicated_list_items'
  get 'verify_products', to: 'pages#verify_products'
  post 'import', to: 'pages#import'
  get 'thank_you', to: "pages#thank_you"
  get 'profile', to: 'pages#profile'
  get 'products', to: "pages#products"
  get 'meals', to: "pages#meals"
  get 'select', to: "pages#select"
  get 'select_products', to: 'pages#select_products'
  get 'select_recipes', to: 'pages#select_recipes'
  get 'explore_recipes', to: 'pages#explore_recipes'
  get 'browse_category', to: 'pages#browse_category'
  get 'search_recipes', to: 'pages#search_recipes'
  get 'add_recipe', to: "pages#add_recipe"
  get 'remove_recipe', to: "pages#remove_recipe"
  get 'get_list', to: "pages#get_list"
  get 'add_to_list', to: "pages#add_to_list"
  get 'explore', to: "pages#explore"
  get 'browse', to: "pages#browse"
  get 'add_to_list_modal', to: "pages#add_to_list_modal"
  get 'select_list', to: 'pages#select_list'
  get 'cuisine', to: 'pages#cuisine'
  get 'history', to: 'pages#history'
  get 'favorites', to: 'pages#favorites'
  get 'add_to_favorites', to: 'pages#add_to_favorites'
  get 'remove_from_favorites', to: 'pages#remove_from_favorites'
  get 'fetch_ios_install', to: 'pages#fetch_ios_install'
  get 'fetch_android_install', to: 'pages#fetch_android_install'
  get 'start', to:'pages#start'
  get 'fetch_landing', to:'pages#fetch_landing'
  get 'assistant', to: 'pages#assistant'
  get 'refresh_assistant', to:'pages#refresh_assistant'
  get 'refresh_meal', to:'pages#refresh_meal'
  get 'activity', to: 'pages#activity'
  get 'get_score', to: 'pages#get_score'
  get 'users', to: 'pages#users'
  get 'add_to_beta', to: 'pages#add_to_beta'
  get 'add_to_homescreen', to: 'pages#add_to_homescreen'
  get 'beta', to:'pages#beta'
  get 'check_user', to:'pages#check_user'
  get 'dislike_recipe', to: 'pages#dislike_recipe'
  get 'remove_recipe_from_dislikes', to: 'pages#remove_recipe_from_dislikes'


  resources :recipes do
    collection do
      get 'import', to: 'recipes#import'
      post :import_recipes
      get :manage
      get :fetch_suggested_recipes
      get :fetch_menu
      get :add_menu_to_list
      get :fetch_recipes
      get :recommend
      get :next
      get :analytics
      get :visualization
      get :visualize
    end
    member do
      # get 'card', to: "recipes#card"
      get :set_published_status
      get :set_dismissed_status
      get :cart
      get :god_show
      get :add_to_list
      get :fetch_recipe_card
      get :add_to_menu
      get :select_all
      get :edit_modal
      get :update_servings
      get :click
    end
    resources :items do
      get :add_to_list
    end
  end

  resources :items do
    get :validate
    get :select
    get :unselect
    collection do
      get :edit_multiple
      put :update_multiple
      get :dislike
    end
  end


  resources :lists do
    get :fetch_item_form
    get :fetch_suggested_items
    get :fetch_saved_items
    get :fetch_completed_items
    get :fetch_category
    get 'fetch_price', to: "lists#fetch_price"
    get 'get_cart', to: "lists#get_cart"
    post 'email', to: "lists#email"
    post 'send_invite', to: "lists#send_invite"
    get 'accept_invite', to: "lists#accept_invite"
    get :archive
    get :save
    get :copy
    get :get_store_carts
    get :add
    get :get_suggested_items
    get :sort
    get :remove_recipe
    get :share
    get :select_all
    get :get_edit_history
    get :get_score
    get :get_score_preview
    get :get_rating_progress
    get :analyze
    get :discover
    resources :items, only: [ :create, :show, :destroy, :edit, :update ] do
      get :complete
      get :uncomplete
      get :edit_modal
    end
    resources :list_items, only: [ :create, :show, :destroy, :edit, :update ] do
      collection do
        patch :sort
      end
      get :complete
      get :uncomplete
      get :edit_modal
      # resources :items do
      #   get 'validate', to: "items#validate"
      #   get 'unvalidate', to: "items#unvalidate"
      # end
      get 'report', to: "products#report"
      get 'search', to: "products#search"
    end
    resources :collaborations, only: [:create, :destroy]
  end

  resources :categories do
    get :unselect
    get :fetch_similar
    collection do
      get :select
      get :tree
    end
  end

  resources :carts do
    post 'share', to: "carts#share"
    post 'special_share', to: "carts#special_share"
    get :fetch_price
    get :order
    member do
      get 'search', to: "carts#search"
      get :add_to_cart
    end
    resources :cart_items, only: [:show, :destroy, :edit, :update] do
      get 'report', to: "products#report"
      get :search
    end
  end

  resources :recipe_lists do
    resources :recipe_list_items, only: [:show, :destroy, :edit, :update]
    member do
      get :explore
      get :add_recipe
      get :add_to_list
      get :fetch_recipes
      get :get_size
      get :search
      get :category
      get :clean
    end
  end


  resources :foods

  resources :products do
    collection do
      get :advanced_search
      get :edit_multiple
      put :update_multiple
    end
  end

  resources :store_carts do
    collection do
      get :fetch_price
    end
    member do
      get :add_to_cart
      get :fetch_items
      get :search
    end
    resources :store_cart_items do
      get :search
      get :fetch_index
    end
  end

  resources :orders

  resources :stores do
    get :store_section
    resources :store_section_items
  end
  #   resources :store_carts do
  #     get 'fetch_price', to: "store_carts#fetch_price"
  #     member do
  #       get :add_to_cart
  #     end
  #     resources :store_cart_items do
  #       get :search
  #       get :fetch_index
  #     end
  #   end
  #   get :catalog
  #   get :cart
  # end

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

  resources :checklists do
    get :select
    resources :checklist_items
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

  # redirect to root if no rooting match
  get '*path' => redirect('/')
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
