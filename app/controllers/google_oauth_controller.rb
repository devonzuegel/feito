# app/controllers/google_oauth_controller.rb
class GoogleOauthController < ApplicationController
  require 'google/api_client/client_secrets'
  before_action :authenticate_user!, only: %i(calendars)

  # TODO: Edge cases to consider.
  #
  # - If the user cancels at the consent screen Google will redirect back
  #   to the callback action with an error parameter instead of the code parameter.
  #
  # - Calling the API might fail for other reasons, so you might also want to
  #   handle other response errors (response.data will have an 'error' key
  #   instead of the 'items' key).

  def redirect
    GoogleOauth.revoke_access(current_user)
    authorization_uri = GoogleOauth.authorization_uri(url_for(action: :callback))
    redirect_to authorization_uri.to_s
  end

  def callback
    response = GoogleOauth.fetch_access_token!(params[:code], url_for(action: :callback))
    current_user.update_access(response)
    redirect_to calendars_path
  end

  def revoke
    GoogleOauth.revoke_access(current_user)
    redirect_to root_path, alert: 'Your Google+ account has been disconnected.'
  end

  def calendars
    @calendars = GoogleCalendar.new(current_user).list
  end
end
