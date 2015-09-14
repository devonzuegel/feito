RSpec.configure do |config|
  config.include SpecUtils
  config.include RoutingUtils
  config.include Omniauth::Mock
  config.include Omniauth::SessionHelpers, type: :feature
end
OmniAuth.config.test_mode = true
