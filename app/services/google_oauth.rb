require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'fileutils'

class GoogleOauth
  AUTH_URL = 'https://www.googleapis.com/auth'

  def initialize(_args)
  end

  def self.scope(names)
    names.map { |name| "#{AUTH_URL}/#{name}" }.join(' ')
  end
end
