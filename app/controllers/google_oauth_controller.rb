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
    google_calendar_api = google_api_client.discovered_api('calendar', 'v3')
    response = google_api_client.execute(
      api_method: google_calendar_api.calendar_list.list,
      parameters: {}
    )

    @calendars = response.data['items']
  end

  private

  def authorization_client
    google_api_client = Google::APIClient.new(app_info)
    google_api_client.authorization = Signet::OAuth2::Client.new(
      client_id:          ENV.fetch('google_api_client_id'),
      client_secret:      ENV.fetch('google_api_client_secret'),
      authorization_uri:  AUTHORIZATION_URI,
      scope:              GoogleOauth.scope(%w(userinfo.email userinfo.profile calendar)),
      redirect_uri:       url_for(action: :callback),
      access_type:        'offline',
      prompt:             'consent',
      approval_prompt:    'force'
    )
    google_api_client
  end

  def token_request_client
    google_api_client = Google::APIClient.new(app_info)
    google_api_client.authorization = Signet::OAuth2::Client.new(
      client_id:            ENV.fetch('google_api_client_id'),
      client_secret:        ENV.fetch('google_api_client_secret'),
      token_credential_uri: TOKEN_CREDENTIAL_URI,
      redirect_uri:         url_for(action: :callback),
      code:                 params[:code]
    )
    google_api_client
  end

  def refresh_auth_request_client
    google_api_client = Google::APIClient.new(app_info)
    google_api_client.authorization = Signet::OAuth2::Client.new(
      client_id:            ENV.fetch('google_api_client_id'),
      client_secret:        ENV.fetch('google_api_client_secret'),
      token_credential_uri: TOKEN_CREDENTIAL_URI,
      refresh_token:        session[:refresh_token],
      grant_type:           'refresh_token'
    )
    google_api_client
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
    google_api_client = Google::APIClient.new(app_info)
    google_api_client.authorization = Signet::OAuth2::Client.new(
      client_id:     ENV.fetch('google_api_client_id'),
      client_secret: ENV.fetch('google_api_client_secret'),
      access_token:  session[:access_token],
      expires_at:    DateTime.parse(session[:expires_at])
    )
    valid_access_token(google_api_client)
  end

  def update_session_auth(response = nil, all_nil: false)
    if all_nil
      session[:access_token]  = nil
      session[:expires_at]    = nil
      session[:refresh_token] = nil
    else
      fail 'MissingGoogleAccessToken' if response['access_token'].nil?
      session[:access_token]  = response['access_token']
      session[:expires_at]    = response['expires_in'].seconds.from_now.to_s
      session[:refresh_token] ||= response['refresh_token']
    end
  end

  def revoke_access
    return if session[:access_token].nil?

    uri       = URI(REVOKE_ACCESS_URI)
    uri.query = URI.encode_www_form(token: session[:access_token])

    response  = Net::HTTP.get(uri)
    logger.info(response)

    update_session_auth(all_nil: true)
  end
end
