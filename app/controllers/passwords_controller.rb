class PasswordsController < ActionController::Base
 def change_password
    user = User.find current_user.id
    raw, enc = Devise.token_generator.generate(user.class, :reset_password_token)
    user.reset_password_token   = enc
    user.reset_password_sent_at = Time.now.utc
    user.save(:validate => false)

    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(current_user))
    redirect_to edit_password_url(user, :reset_password_token => raw)
  end

end
