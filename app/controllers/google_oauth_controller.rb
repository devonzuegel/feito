# app/controllers/google_oauth_controller.rb
class GoogleOauthController < ApplicationController
  require 'google/api_client/client_secrets'

  APPLICATION_NAME     = 'Feito'
  APPLICATION_VERSION  = '0.0.0'
  AUTHORIZATION_URI    = 'https://accounts.google.com/o/oauth2/auth'
  TOKEN_CREDENTIAL_URI = 'https://accounts.google.com/o/oauth2/token'
  REVOKE_ACCESS_URI    = 'https://accounts.google.com/o/oauth2/revoke'

  # TODO: Edge cases to consider.
  #
  # - If the user cancels at the consent screen Google will redirect back
  #   to the callback action with an error parameter instead of the code parameter.
  #
  # - Calling the API might fail for other reasons, so you might also want to
  #   handle other response errors (response.data will have an 'error' key
  #   instead of the 'items' key).

  def redirect
    revoke_access
    authorization_uri = authorization_client.authorization.authorization_uri
    redirect_to authorization_uri.to_s
  end

  def callback
    response = token_request_client.authorization.fetch_access_token!
    update_session_auth(response)
    redirect_to calendars_path
  end

  def calendars
    client = google_api_client
    google_calendar_api = client.discovered_api('calendar', 'v3')
    response = client.execute(
      api_method: google_calendar_api.calendar_list.list,
      parameters: {}
    )

    @calendars = response.data['items']
  end

  private

  def authorization_client
    client = Google::APIClient.new(app_info)
    client.authorization = Signet::OAuth2::Client.new(
      client_id:          ENV.fetch('google_api_client_id'),
      client_secret:      ENV.fetch('google_api_client_secret'),
      authorization_uri:  AUTHORIZATION_URI,
      scope:              GoogleOauth.scope(%w(userinfo.email userinfo.profile calendar)),
      redirect_uri:       url_for(action: :callback),
      access_type:        'offline',
      prompt:             'consent',
      approval_prompt:    'force'
    )
    client
  end

  def token_request_client
    client = Google::APIClient.new(app_info)
    client.authorization = Signet::OAuth2::Client.new(
      client_id:            ENV.fetch('google_api_client_id'),
      client_secret:        ENV.fetch('google_api_client_secret'),
      token_credential_uri: TOKEN_CREDENTIAL_URI,
      redirect_uri:         url_for(action: :callback),
      code:                 params[:code]
    )
    client
  end

  def refresh_auth_request_client
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

  def valid_access_token(client)
    return client unless client.authorization.expired?

    client = refresh_auth_request_client
    response = client.authorization.fetch_access_token!
    update_session_auth(response)
    client
  end

  def app_info
    {
      application_name:    APPLICATION_NAME,
      application_version: APPLICATION_VERSION
    }
  end

  def google_api_client
    client = Google::APIClient.new(app_info)
    client.authorization = Signet::OAuth2::Client.new(
      client_id:     ENV.fetch('google_api_client_id'),
      client_secret: ENV.fetch('google_api_client_secret'),
      access_token:  current_user.access_token,
      expires_at:    current_user.expires_at
    )
    valid_access_token(client)
  end

  def update_session_auth(response)
    fail 'MissingGoogleAccessToken' if response['access_token'].nil?
    current_user.update_attributes!(
      access_token:  response.fetch('access_token'),
      expires_at:    response.fetch('expires_in').seconds.from_now,
      refresh_token: current_user.refresh_token || response['refresh_token']
    )
  end

  def clear_session_auth
    current_user.update_attributes(
      access_token:  nil,
      expires_at:    nil,
      refresh_token: nil
    )
  end

  def revoke_access
    return if current_user.access_token.nil?

    uri       = URI(REVOKE_ACCESS_URI)
    uri.query = URI.encode_www_form(token: current_user.access_token)

    response  = Net::HTTP.get(uri)
    logger.info(response)

    clear_session_auth
  end
end
