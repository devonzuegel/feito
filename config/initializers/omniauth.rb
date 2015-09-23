Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['omniauth_provider_key'], ENV['omniauth_provider_secret']
end
