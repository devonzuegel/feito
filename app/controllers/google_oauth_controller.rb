# app/controllers/google_oauth_controller.rb
class GoogleOauthController < ApplicationController
  require 'google/api_client/client_secrets'

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
    session[:access_token] = auth_client.access_token
    ap session[:access_token]
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

  def client_secrets
    Google::APIClient::ClientSecrets.new('web' => {
                                           client_id:      ENV['google_client_id'],
                                           client_secret:  ENV['google_client_secret']
                                         })
  end
end
