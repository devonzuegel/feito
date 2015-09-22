# app/controllers/google_oauth_controller.rb
class GoogleOauthController < ApplicationController
  require 'google/api_client/client_secrets'

  REFRESH_URL = 'https://accounts.google.com/o/oauth2/token'

  def connect
    auth_client = client_secrets.to_authorization
    auth_client.update!(
      scope:        GoogleOauth.scope(%w(userinfo.email calendar)),
      redirect_uri: "#{ENV['domain']}/auth/google/callback"
    )
    auth_uri = auth_client.authorization_uri.to_s
    redirect_to(auth_uri)
  end

  def callback
    auth_client = client_secrets.to_authorization
    auth_client.update!(
      scope:        GoogleOauth.scope(%w(userinfo.email calendar)),
      redirect_uri: "#{ENV['domain']}/auth/google/callback"
    )

    auth_client.code = request['code']
    auth_client.fetch_access_token!
    auth_client.client_secret = nil

    session[:access_token]  = auth_client.access_token
    session[:refresh_token] = auth_client.refresh_token
    session[:expires_in]    = auth_client.expires_in  # Seconds until token expires
    session[:issued_at]     = auth_client.issued_at   # Time token was issued

    redirect_to calendars_path
  end

  def calendars
    # TODO: Reconnect if it is invalid, as well!
    redirect_to connect_path if session[:access_token].nil?

    client = Google::APIClient.new
    client.authorization.access_token = session[:access_token]
    service = client.discovered_api('calendar', 'v3')

    @calendars = client.execute(
      api_method: service.calendar_list.list,
      parameters: {},
      headers:    { 'Content-Type' => 'application/json' }
    ).data.items
  end

  private

  # # Private: OAuth 2.0 credentials containing an access and refresh token
  # #
  # # Return
  # #   [Signet::Oauth2::Client] - Returns fresh credentials.
  # def refreshed_client
  #   credentials = get_stored_credentials

  #   # If unavailable, exchange the refresh_token to obtain a new access_token.
  #   if credentials.blank?
  #     credentials = exchange_refresh_token
  #     store_credentials(email_address, credentials)
  #   elsif credentials_expired?(credentials)
  #     credentials = exchange_refresh_token
  #     store_credentials(email_address, credentials)
  #   end

  #   credentials
  # end

  # # Private: stores provided credentials
  # #
  # # Params
  # #   credentials [Signet::Oauth2::Client] - credentials to store
  # def store_credentials(credentials)
  #   session[:refresh_token] = credentials.authorization.refresh_token
  #   session[:access_token]  = credentials.authorization.access_token
  # end

  # # Private: Retrieve stored credentials for current user.
  # #
  # # Return
  # #   [Signet::OAuth2::Client] - credentials recreatedz from session store.
  # def get_stored_credentials
  #   client = Google::APIClient.new

  #   client.authorization.client_id     = ENV['google_client_id']
  #   client.authorization.client_secret = ENV['google_client_secret']
  #   client.authorization.grant_type    = 'refresh_token'
  #   client.authorization.refresh_token = session[:refresh_token]
  #   client.authorization.access_token  = session[:access_token]

  #   client.authorization
  # end

  # # Private: Exchange the refresh token for a new access token.
  # #
  # # Return
  # #   [Signet::Oauth::Client::Authorization] - Refreshed authorization
  # def exchange_refresh_token
  #   client = Google::APIClient.new

  #   client.authorization.client_id     = ENV['google_client_id']
  #   client.authorization.client_secret = ENV['google_client_secret']
  #   client.authorization.grant_type    = 'refresh_token'
  #   client.authorization.refresh_token = session[:refresh_token]

  #   client.authorization.fetch_access_token!
  #   client.authorization
  # end

  # def credentials_expired?(credentials)
  #   client  = Google::APIClient.new
  #   client.authorization = credentials
  #   oauth2  = client.discovered_api('oauth2', 'v2')
  #   # service = client.discovered_api('calendar', 'v3')
  #   result  = client.execute(
  #     api_method: oauth2.userinfo.get,
  #     parameters: {},
  #     headers:    { 'Content-Type' => 'application/json' }
  #   )
  #   (result.status != 200)
  # end

  def client_secrets
    Google::APIClient::ClientSecrets.new('web' => {
                                           client_id:      ENV['google_client_id'],
                                           client_secret:  ENV['google_client_secret']
                                         })
  end

  # def refreshed_client
  #   client = Google::APIClient.new

  #   client.authorization.client_id     = ENV['google_client_id']
  #   client.authorization.client_secret = ENV['google_client_secret']
  #   client.authorization.grant_type    = 'refresh_token'
  #   client.authorization.refresh_token = session[:refresh_token]

  #   # session[:access_token]  = auth_client.access_token
  #   # session[:refresh_token] = auth_client.refresh_token
  #   # session[:expires_in]    = auth_client.expires_in  # Seconds until token expires
  #   # session[:issued_at]     = auth_client.issued_at   # Time token was issued

  #   client.authorization.fetch_access_token! if client.authorization.expired?

  #   session[:access_token]  = client.access_token
  #   session[:refresh_token] = client.refresh_token
  #   session[:expires_in]    = client.expires_in  # Seconds until token expires
  #   session[:issued_at]     = client.issued_at   # Time token was issued

  #   client
  # end

  # def refresh_token
  #   data = {
  #     client_id:     ENV['google_client_id'],
  #     client_secret: ENV['google_client_secret'],
  #     refresh_token: session[:refresh_token],
  #     grant_type:    'refresh_token'
  #   }
  #   @response = ActiveSupport::JSON.decode(RestClient.post REFRESH_URL, data)
  #   if @response['access_token'].present?
  #     # Save your token
  #   else
  #     # No Token
  #   end
  # rescue RestClient::BadRequest => e
  #   # Bad request
  # rescue
  #   # Something else bad happened
  # end
end
