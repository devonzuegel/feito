# app/controllers/google_oauth_controller.rb
class GoogleOauthController < ApplicationController
  require 'google/api_client/client_secrets'
  before_action :authenticate_user!, only: %i(calendars)

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
    authorization_uri = GoogleOauth.authorization_uri(url_for(action: :callback))
    redirect_to authorization_uri.to_s
  end

  def callback
    response = GoogleOauth.fetch_access_token!(params[:code], url_for(action: :callback))
    current_user.update_access(response)
    redirect_to calendars_path
  end

  def calendars
    @calendars = GoogleCalendar.new(current_user).list
  end

  private

  def revoke_access
    return if current_user.access_token.nil?

    uri       = URI(REVOKE_ACCESS_URI)
    uri.query = URI.encode_www_form(token: current_user.access_token)

    response  = Net::HTTP.get(uri)
    logger.info(response)

    current_user.revoke_access
  end
end
