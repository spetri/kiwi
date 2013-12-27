class RegistrationsController < Devise::RegistrationsController

  def new
    build_resource(session['omniauth.payload'])
    respond_with self.resource
  end

  def update
    @user = User.find(current_user.id)

    if @user.update_without_password(account_update_params)
      set_flash_message :notice, :updated
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end


end
