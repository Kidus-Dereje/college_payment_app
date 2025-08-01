Rails.application.routes.draw do
  namespace :api do
    get 'wallet/:user_id/balance', to: 'wallets#balance'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    get 'health', to: 'health#index'
    resources :students, only: [:index] do
      collection do
        post :bulk_create_users
      end
    end
    post 'login', to: 'sessions#create'
  end

  get 'students/credentials_summary', to: 'students#credentials_summary'
end
