Rails.application.routes.draw do
  resources :games, only: [:create] do
    resources :frames, only: [:create, :update]
  end
end
