Rails.application.routes.draw do
  root 'pages#home'

  get 'home', to: 'pages#home'
  get 'services', to: 'pages#services'
  resources :categories, only: [:index, :show]
end
