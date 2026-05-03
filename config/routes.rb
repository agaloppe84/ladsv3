Rails.application.routes.draw do
  devise_for :users

  namespace :admin_v2, path: "admin-v2" do
    root to: "products#index"

    resources :products, only: [:index, :show, :edit] do
      resource :details, only: [:update], controller: "product_details"
      resource :category, only: [:update], controller: "product_categories"
      resource :associations, only: [:update], controller: "product_associations"
      resource :service, only: [:update], controller: "product_services"

      resources :media_items, path: "media", only: [:create, :destroy], controller: "product_media" do
        get :drawer, on: :collection
        patch :reorder, on: :collection
      end

      resources :documentations, only: [:create, :destroy], controller: "product_documentations" do
        get :drawer, on: :collection
      end

      resources :options, only: [:create, :update, :destroy], controller: "product_options" do
        get :drawer, on: :collection
        patch :reorder, on: :collection
      end

      resources :color_parts, only: [:create, :update, :destroy], controller: "product_color_parts" do
        resources :items, only: [:create, :update, :destroy], controller: "color_palette_items"
      end

      resources :finishes, only: [:create]
    end
  end

  namespace :admin do
    resources :categories
    resources :options
    resources :events
    resources :quotes
    resources :destock_products do
      resources :options, only: [:create, :destroy]
    end
    resources :products do
      resources :options, only: [:create, :destroy]
    end
    resources :product_configurators, only: [:index, :show] do
      member do
        post :create_part
        patch "parts/:part_id", action: :update_part, as: :part
        delete "parts/:part_id", action: :destroy_part, as: :destroy_part

        post "parts/:part_id/items", action: :create_item, as: :part_items
        patch "parts/:part_id/items/:item_id", action: :update_item, as: :part_item
        delete "parts/:part_id/items/:item_id", action: :destroy_item, as: :destroy_item

        post :create_finish
      end
    end
    resources :motorists
    resources :manufacturers
    resources :rals

    root to: "products#index"
  end
  root 'pages#home'

  get 'home', to: 'pages#home'
  get 'services', to: 'pages#services'
  get 'destock', to: 'pages#destock'
  get 'contact', to: 'pages#contact'
  resources :categories, only: [:index, :show]
  resources :products, only: [:show], path: 'produits', param: :slug do
    member do
      get :canvas_selector
    end
  end
  resources :quotes, only: [:new, :create], path: 'devis'
end
