Rails.application.routes.draw do
  root "events#index"
  resources :events, only: [:index, :show, :new, :create]
end

