Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, Rails.application.secrets.omniauth_provider_key,
           Rails.application.secrets.omniauth_provider_secret

  # More details at //baugues.com/google-calendar-api-oauth2-and-ruby-on-rails.
  provider :google_oauth2, GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, {
    access_type:  'offline',
    scope:        'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/calendar',
    redirect_uri: 'http://localhost/auth/google_oauth2/callback'
  }
end
