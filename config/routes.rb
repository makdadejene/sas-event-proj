Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  

  root "events#index"
  resources :events do
    member do
      post 'upvote'
    end
  end

  resources :events do
    # Nested upvotes route
    resources :upvotes, only: [:create]
  end
  
  # Route for removing upvotes
  resources :upvotes, only: [:destroy]
end