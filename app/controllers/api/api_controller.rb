# app/controllers/api/api_controller.rb
class Api::ApiController < ActionController::Base
  include ActionController::ImplicitRender

  respond_to :json
  before_action :authenticate!

  private

  # If given a valid token, retrieve the correct @user.
  # If given an invalid token, fail the request and explain.
  def authenticate!
    @user = User.find_by(api_key: params[:api_key])
    return if @user.present?

    response_json = { status: User::INVALID_API_KEY }
    respond_with :api, :v1, response_json, status: :unauthorized
  end
end
