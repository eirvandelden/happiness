Rails.application.routes.draw do
  mount Appkit::Engine => "/"

  namespace :admin do
    root "dashboard#index"
    resources :users
    resources :dashboard, only: [ :index ]
  end
  resources :state_of_minds, only: [ :index, :new, :create ]
  root "state_of_minds#new"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
