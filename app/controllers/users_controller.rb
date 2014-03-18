class UsersController < ApplicationController

  def update
    @user = User.find(current_user.id) 
    @user[:country] = user_params[:country]
    @user[:subkasts] = user_params[:subkasts].split(',')
    @user.save()

    render nothing: true
  end

  private
    def user_params
      params.permit(:country, :subkasts) 
    end
end
