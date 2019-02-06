Rails.application.routes.draw do
  root to: 'posts#index'
  post 'users/login', to: 'users#login'
  get 'users/logout', to: 'users#logout'
  resources :users, only: [:index, :show, :edit]
  resources :posts, only: [:index, :show]
end
