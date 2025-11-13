Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  

  root "events#new"
  resources :events do
    member do
      post 'upvote'
    end
  end

  resources :events do
    # Nested upvotes route
    resources :upvotes, only: [:create]
  end
  
  resources :events do
    member do
      post :upvote
    end
  end
end