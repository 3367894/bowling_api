Rails.application.routes.draw do
  resources :games, only: [:create, :show] do
    resources :frames, only: [:create, :update]
  end
end
