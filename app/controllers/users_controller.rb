class UsersController < ApplicationController

  def update
    @user = User.find(current_user.id)
    @user[:country] = user_params[:country]
    @user[:subkasts] = user_params[:subkasts].split(',')
    @user[:last_posted_country] = user_params[:last_posted_country]
    @user.save()

    render nothing: true
  end

  private
    def user_params
      params.permit(:country, :subkasts, :last_posted_country)
    end
end
