Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV.fetch('omniauth_provider_key'), ENV.fetch('omniauth_provider_secret')
end
