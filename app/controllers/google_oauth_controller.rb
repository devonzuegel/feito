# app/controllers/google_oauth_controller.rb
class GoogleOauthController < ApplicationController
  require 'google/api_client/client_secrets'

  APPLICATION_NAME     = 'Feito'
  APPLICATION_VERSION  = '0.0.0'
  AUTHORIZATION_URI    = 'https://accounts.google.com/o/oauth2/auth'
  TOKEN_CREDENTIAL_URI = 'https://accounts.google.com/o/oauth2/token'

  # TODO:
  # - If the user cancels at the consent screen Google will redirect back
  #   to the callback action with an error parameter instead of the code parameter.
  #
  # - Calling the API will fail if the access token has expired (access
  #   tokens are only valid for an hour). When obtaining the access token
  #   Google will also return a “refresh_token” which you can use to re-request
  #   access tokens directly, without having to re-authorize.
  #
  # - Calling the API might fail for other reasons, so you might also want to
  #   handle other response errors (response.data will have an 'error' key
  #   instead of the 'items' key).

  def redirect
    google_api_client = Google::APIClient.new(app_info)

    google_api_client.authorization = Signet::OAuth2::Client.new({
      client_id:          ENV.fetch('google_api_client_id'),
      client_secret:      ENV.fetch('google_api_client_secret'),
      authorization_uri:  AUTHORIZATION_URI,
      scope:              GoogleOauth.scope(%w(userinfo.email calendar)),
      redirect_uri:       url_for(action: :callback)
    })

    authorization_uri = google_api_client.authorization.authorization_uri
    redirect_to authorization_uri.to_s
  end

  def callback
    google_api_client = Google::APIClient.new(app_info)

    google_api_client.authorization = Signet::OAuth2::Client.new({
      client_id:            ENV.fetch('google_api_client_id'),
      client_secret:        ENV.fetch('google_api_client_secret'),
      token_credential_uri: TOKEN_CREDENTIAL_URI,
      redirect_uri:         url_for(action: :callback),
      code:                 params[:code]
    })

    response = google_api_client.authorization.fetch_access_token!
    session[:access_token] = response['access_token']

    redirect_to url_for(action: :calendars)
  end

  def calendars
    google_api_client = Google::APIClient.new(app_info)

    google_api_client.authorization = Signet::OAuth2::Client.new({
      client_id:     ENV.fetch('google_api_client_id'),
      client_secret: ENV.fetch('google_api_client_secret'),
      access_token:  session[:access_token]
    })

    google_calendar_api = google_api_client.discovered_api('calendar', 'v3')

    response = google_api_client.execute({
      api_method: google_calendar_api.calendar_list.list,
      parameters: {}
    })

    @calendars = response.data['items']
  end

  private

  def app_info
    {
      application_name:    APPLICATION_NAME,
      application_version: APPLICATION_VERSION
    }
  end
end
