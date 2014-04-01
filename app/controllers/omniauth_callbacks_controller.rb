class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :authenticate

  def twitter
    @user = User.omniauth_find(auth_params)
    if @user
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.twitter_uid"] = auth_params[:uid]
      session['omniauth.payload'] = auth_params
      redirect_to  new_user_registration_url , :notice => 'omniauthed'
    end
  end

  def facebook
    @user = User.omniauth_find(auth_params)
    if @user
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_uid"] = auth_params[:uid]
      session['omniauth.payload'] = auth_params
      redirect_to new_user_registration_url, :notice => 'omniauthed'
    end
  end

  alias_method :facebook, :twitter

  private
    def auth_params
      auth = env["omniauth.auth"]
      {
        provider: auth.provider,
        uid: auth.uid,
        name: auth.info.name,
        email: auth.info.email
      }
    end
end
