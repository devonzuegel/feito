Rails.application.routes.draw do
  resources :users, only: %i(edit update destroy)

  # Root
  root to: 'visitors#index'

  # Sign-in and authentication.
  get '/signin'                 => 'sessions#new',     as: :signin
  get '/signout'                => 'sessions#destroy', as: :signout
  get '/auth/facebook/callback' => 'sessions#create',  as: :facebook_callback
  get '/auth/failure'           => 'sessions#failure'

  # Connecting to google.
  get '/auth/google/redirect'   => 'google_oauth#redirect',  as: :google_redirect
  get '/auth/google/callback'   => 'google_oauth#callback',  as: :google_callback
  get '/auth/google/revoke'     => 'google_oauth#revoke',    as: :google_revoke
  get '/calendars'              => 'google_oauth#calendars', as: :calendars

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :tasks do
        get 'steps', on: :member
      end
    end
  end
end
