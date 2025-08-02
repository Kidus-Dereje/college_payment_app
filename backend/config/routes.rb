Rails.application.routes.draw do
  namespace :api do
    get 'wallet/:user_id/balance', to: 'wallets#balance'
    get 'health', to: 'health#index'
    resources :students, only: [:index] do
      collection do
        post :bulk_create_users
      end
    end
    resources :services, only: [:index]
    post 'login', to: 'sessions#create'

    namespace :v1 do
      post 'sign_up_student', to: 'registration#sign_up_student'
      post 'login', to: 'session#create'
      post 'payments/top_up', to: 'payments#top_up'
      post 'payments/callback', to: 'payments#callback'
      post 'payments', to: 'payments#create'
      resources :student, only: [:index, :show]
      resources :bank_accounts, only: [:index, :show, :create, :update, :destroy]
    end
  end

  # Non-API routes for HTML views
  get 'students/email_preview', to: 'students#email_preview'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
