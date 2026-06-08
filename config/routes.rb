Rails.application.routes.draw do
  devise_for :users

  namespace :admin_v2, path: "admin-v2" do
    root to: "products#index"

    resources :products, only: [:index, :show, :new, :create, :edit, :destroy] do
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
        get :drawer, on: :member
        resources :items, only: [:create, :update, :destroy], controller: "color_palette_items"
      end

      resources :finishes, only: [:create]
    end

    resources :events, only: [:index, :show, :new, :create, :edit, :destroy] do
      resource :details, only: [:update], controller: "event_details"
      resource :schedule, only: [:update], controller: "event_schedule"
    end

    resources :categories, only: [:index, :show, :new, :create, :destroy] do
      resource :details, only: [:update], controller: "category_details"
      resource :appearance, only: [:update], controller: "category_appearance"
      resource :publication, only: [:update], controller: "category_publications"
      resource :hero_image, path: "hero-image", only: [:create, :destroy], controller: "category_hero_images"
    end

    resources :quotes, path: "devis", only: [:index, :show] do
      resource :processing, only: [:update], controller: "quote_processing"
    end

    resource :session_storage, path: "session-storage", only: [], controller: "session_storage" do
      post :prune
    end
  end

  namespace :public_v2, path: "public-v2" do
    get "home", to: "pages#home"
    get "categories", to: "categories#index", as: :categories
    get "produits/:slug/selecteur-toile", to: "products#canvas_selector", as: :canvas_selector_product
    get "produits/:slug", to: "products#show", as: :product
    get "devis", to: "quotes#new", as: :new_quote
    post "devis", to: "quotes#create", as: :quotes
    get "contact", to: "pages#contact", as: :contact
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
