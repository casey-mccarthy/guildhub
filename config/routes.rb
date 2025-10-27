Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Discord OAuth Authentication (Epic 2)
  # Callback route for OmniAuth Discord
  get "/auth/:provider/callback", to: "auth/callbacks#create", as: :auth_callback
  get "/auth/failure", to: "auth/callbacks#failure", as: :auth_failure

  # Session management (Epic 2)
  delete "/logout", to: "sessions#destroy", as: :logout

  # Defines the root path route ("/")
  root "home#index"
end
