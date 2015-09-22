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
    @auth_client = auth_client
    @auth_client.code = request['code']
    @auth_client.fetch_access_token!
    @auth_client.client_secret = nil

    session[:access_token]  = @auth_client.access_token
    session[:refresh_token] = @auth_client.refresh_token
    session[:expires_in]    = @auth_client.expires_in  # Seconds until token expires
    session[:issued_at]     = @auth_client.issued_at   # Time token was issued

    redirect_to calendars_path
  end

  def calendars
    redirect_to connect_path if session[:access_token].nil?
    @api_client ||= Google::APIClient.new
    @api_client.authorization.access_token = session[:access_token]

    refresh_auth_token if @api_client.authorization.expired?

    service = @api_client.discovered_api('calendar', 'v3')

    @calendars = @api_client.execute(
      api_method: service.calendar_list.list,
      parameters: {},
      headers:    { 'Content-Type' => 'application/json' }
    ).data.items
  end

  private

  def auth_client
    auth_client = client_secrets.to_authorization
    auth_client.update!(
      scope:        GoogleOauth.scope(%w(userinfo.email calendar)),
      redirect_uri: "#{ENV['domain']}/auth/google/callback"
    )
    auth_client
  end

  def options
    {
      body: {
        client_id:     ENV['google_client_id'],
        client_secret: ENV['google_client_secret'],
        refresh_token: session[:refresh_token],
        grant_type:    'refresh_token'
      },
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
    }
  end

  def refresh_auth_token
    @api_client ||= Google::APIClient.new
    @response = HTTParty.post('https://accounts.google.com/o/oauth2/token', options)
    if @response.code == 200
      @api_client.token = @response.parsed_response['access_token']
      @api_client.expires_in = DateTime.now + @response.parsed_response['expires_in'].seconds
      @api_client.save
    else
      Rails.logger.error('Unable to refresh google_oauth2 authentication token.')
      Rails.logger.error("Refresh token response body: #{@response.body}")
    end
  end

  def client_secrets
    Google::APIClient::ClientSecrets.new('web' => {
                                           client_id:      ENV['google_client_id'],
                                           client_secret:  ENV['google_client_secret']
                                         })
  end
end
