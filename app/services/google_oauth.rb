# feito/app/services/google_oauth.rb
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'fileutils'

class GoogleOauth
  APPLICATION_NAME     = 'Feito'
  APPLICATION_VERSION  = '0.0.0'

  AUTH_URL             = 'https://www.googleapis.com/auth'
  TOKEN_CREDENTIAL_URI = 'https://accounts.google.com/o/oauth2/token'
  AUTHORIZATION_URI    = 'https://accounts.google.com/o/oauth2/auth'
  REVOKE_ACCESS_URI    = 'https://accounts.google.com/o/oauth2/revoke'

  def self.api_client(user)
    client = Google::APIClient.new(app_info)
    client.authorization = Signet::OAuth2::Client.new(
      client_id:     ENV.fetch('google_api_client_id'),
      client_secret: ENV.fetch('google_api_client_secret'),
      access_token:  user.access_token,
      expires_at:    user.expires_at
    )
    valid_access_token(client, user)
  end

  def self.fetch_access_token!(code, redirect_uri)
    client = Google::APIClient.new(app_info)
    client.authorization = Signet::OAuth2::Client.new(
      client_id:            ENV.fetch('google_api_client_id'),
      client_secret:        ENV.fetch('google_api_client_secret'),
      token_credential_uri: TOKEN_CREDENTIAL_URI,
      redirect_uri:         redirect_uri,
      code:                 code
    )
    client.authorization.fetch_access_token!
  end

  def self.authorization_uri(redirect_uri)
    client = Google::APIClient.new(app_info)
    client.authorization = Signet::OAuth2::Client.new(
      client_id:          ENV.fetch('google_api_client_id'),
      client_secret:      ENV.fetch('google_api_client_secret'),
      authorization_uri:  AUTHORIZATION_URI,
      scope:              scope(%w(userinfo.email userinfo.profile calendar)),
      redirect_uri:       redirect_uri,
      access_type:        'offline',
      prompt:             'consent',
      approval_prompt:    'force'
    )
    client.authorization.authorization_uri
  end

  def self.revoke_access(user)
    return if user.access_token.nil?

    uri       = URI(REVOKE_ACCESS_URI)
    uri.query = URI.encode_www_form(token: user.access_token)
    response  = Net::HTTP.get(uri)

    user.revoke_access
  end

  private

  def self.scope(names)
    names.map { |name| "#{AUTH_URL}/#{name}" }.join(' ')
  end

  def self.app_info
    {
      application_name:    APPLICATION_NAME,
      application_version: APPLICATION_VERSION
    }
  end

  def self.valid_access_token(client, user)
    return client unless client.authorization.expired?

    client = refresh_auth_request_client(user)
    response = client.authorization.fetch_access_token!
    user.update_access(response)
    client
  end

  def self.refresh_auth_request_client(user)
    client = Google::APIClient.new(app_info)
    client.authorization = Signet::OAuth2::Client.new(
      client_id:            ENV.fetch('google_api_client_id'),
      client_secret:        ENV.fetch('google_api_client_secret'),
      token_credential_uri: TOKEN_CREDENTIAL_URI,
      refresh_token:        user.refresh_token,
      grant_type:           'refresh_token'
    )
    client
  end
end
