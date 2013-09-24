class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :authenticate
  def twitter
    auth = env["omniauth.auth"]
  
    @user = User.from_omniauth(auth)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.twitter_uid"] = auth["uid"]
      redirect_to new_user_registration_url
    end
  end
  
  def facebook
    @user = User.from_omniauth(auth)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_uid"] = auth["uid"]
      redirect_to new_user_registration_url
    end
  end

  alias_method :facebook, :twitter
end
