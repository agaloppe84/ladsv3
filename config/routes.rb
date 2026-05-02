Rails.application.routes.draw do
  devise_for :users
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
