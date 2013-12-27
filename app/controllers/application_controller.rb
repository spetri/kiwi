class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout :layout_by_resource

  protected

  def layout_by_resource
    if devise_controller?
      "no_backbone"
    else
      "application"
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) do |u|
      u.permit(:username, :password, :email)
    end

    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:username, :name, :email,
               :provider, :uid, :image, :oauth_token, :oauth_expires_at,
               :password, :password_confirmation)
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:username, :name, :email,
               :provider, :uid, :oauth_token, :oauth_expires_at,
               :password, :password_confirmation)
    end
  end
end
