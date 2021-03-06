# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :signed_in?, :correct_user?
  before_action :development_signin

  private

  def development_signin
    # reset_session
    # session[:user_id] ||= User.first.id if Rails.env == 'development'
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def signed_in?
    current_user.present?
  end

  def correct_user?
    @user = User.find(params[:id])
    redirect_to root_url, alert: 'Access denied.' unless current_user == @user
  end

  def authenticate_user!
    msg = 'You need to sign in for access to this page.'
    redirect_to root_url, alert: msg unless signed_in?
  end
end
