# app/controllers/google_oauth_controller.rb
class GoogleOauthController < ApplicationController
  require 'google/api_client/client_secrets'
  before_action :authenticate_user!, only: %i(calendars)

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
    current_user.update_access(response)
    redirect_to calendars_path
  end

  def calendars
    ap current_user
    client = GoogleOauth.api_client(current_user)
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

  def app_info
    {
      application_name:    APPLICATION_NAME,
      application_version: APPLICATION_VERSION
    }
  end

  def revoke_access
    return if current_user.access_token.nil?

    uri       = URI(REVOKE_ACCESS_URI)
    uri.query = URI.encode_www_form(token: current_user.access_token)

    response  = Net::HTTP.get(uri)
    logger.info(response)

    current_user.revoke_access
  end
end
