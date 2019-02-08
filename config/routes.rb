Rails.application.routes.draw do
  root to: 'posts#index'
  post 'users/login', to: 'users#login'
  get 'users/logout', to: 'users#logout'
  get 'users', to: 'users#index'
  post 'users/edit', to: 'users#edit'
  resources :posts, only: [:index, :show]
end
