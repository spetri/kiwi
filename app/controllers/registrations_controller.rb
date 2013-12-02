class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, if: :devise_controller?    

  def new
    build_resource(session['omniauth.payload'])
    respond_with self.resource
  end


  def update
    super
  end


  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:username, :name, :email,
               :provider, :uid, :image, :oauth_token, :oauth_expires_at,
               :password, :password_confirmation, :current_password)
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:username, :name, :email,
               :provider, :uid, :oauth_token, :oauth_expires_at, 
               :password, :password_confirmation, :current_password)
    end
  end
end
