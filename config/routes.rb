Rails.application.routes.draw do
  devise_for :users
  namespace :admin do
    resources :categories
    resources :options
    resources :products
    resources :brands
    resources :motorists

    root to: "categories#index"
  end
  root 'pages#home'

  get 'home', to: 'pages#home'
  get 'services', to: 'pages#services'
  resources :categories, only: [:index, :show]
  resources :products, only: [:show]
  resources :quotes, only: [:new, :create]
end
