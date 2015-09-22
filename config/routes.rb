Rails.application.routes.draw do
  resources :users, only: %i(edit update destroy)

  # Root
  root to: 'visitors#index'

  # Sign-in and authentication.
  get '/auth/facebook/callback' => 'sessions#create'
  get '/signin'                 => 'sessions#new',         as: :signin
  get '/signout'                => 'sessions#destroy',     as: :signout
  get '/auth/failure'           => 'sessions#failure'

  # Connecting to google
  get '/connect'                => 'google_oauth#connect', as: :connect
  get '/auth/google/callback'   => 'google_oauth#callback'
  get '/calendars'              => 'google_oauth#calendars', as: :calendars

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :tasks do
        get 'steps', on: :member
      end
    end
  end
end
