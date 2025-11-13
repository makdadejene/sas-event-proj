Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  
  root "events#new"
  
  resources :events do
    member do
      post 'upvote'
    end
    resources :upvotes, only: [:create, :destroy]
  end
end