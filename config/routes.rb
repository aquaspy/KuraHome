Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get  "signup", to: "registrations#new", as: :signup
  post "signup", to: "registrations#create"
  get  "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get  "unlock", to: "locks#show", as: :unlock
  post "unlock", to: "locks#create"
  post "lock", to: "locks#lock", as: :lock
  post "auto_lock", to: "locks#toggle_auto_lock", as: :auto_lock
  resource :password, only: %i[edit update]

  resources :profiles, only: %i[create update destroy]
  resources :sites, only: %i[create update destroy] do
    collection { patch :reorder }
  end
  resources :stack_items, only: %i[create update destroy] do
    collection { patch :reorder }
    member { get :icon }
  end

  get "stack", to: "home#stack", as: :stack
  root "home#index"
end
