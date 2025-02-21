Rails.application.routes.draw do
  devise_for :users
  namespace :admin do
    resources :categories
    resources :options
    resources :events
    resources :quotes
    resources :products do
      resources :options, only: [:create, :destroy]
    end
    resources :brands
    resources :motorists

    root to: "products#index"
  end
  root 'pages#home'

  get 'home', to: 'pages#home'
  get 'services', to: 'pages#services'
  get 'destock', to: 'pages#destock'
  resources :categories, only: [:index, :show]
  resources :products, only: [:show]
  resources :quotes, only: [:new, :create]
end
