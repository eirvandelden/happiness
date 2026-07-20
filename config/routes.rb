Rails.application.routes.draw do
  # Overrides Appkit::Engine's session route to route to the local SessionsController
  # (which restores sign-in/sign-out flash messages). Must be declared before the engine
  # mount so it takes precedence.
  resource :session, only: %i[new create destroy], controller: "sessions" do
    resources :transfers, only: %i[show update], controller: "appkit/sessions/transfers"
  end

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
