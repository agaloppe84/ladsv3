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
    resources :motorists
    resources :manufacturers

    root to: "products#index"
  end
  root 'pages#home'

  get 'home', to: 'pages#home'
  get 'services', to: 'pages#services'
  get 'destock', to: 'pages#destock'
  get 'contact', to: 'pages#contact'
  resources :categories, only: [:index, :show]
  resources :products, only: [:show]
  resources :quotes, only: [:new, :create]
end
