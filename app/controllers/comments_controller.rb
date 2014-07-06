class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :update]
  authorize_resource :only => [:destroy]

  def new
    @comment = Comment.new
  end

  def show
  end

  def create
    params = comment_params.dup
    have_i_upvoted = params.delete :have_i_upvoted
    have_i_downvoted = params.delete :have_i_downvoted

    @comment = Comment.new(params)
    @comment.setup_params(params)

    @comment.event = Event.find(params[:event_id])
    unless params[:parent_id].nil?
      Comment.find(params[:parent_id]).new_comment @comment
    end

    @comment.update_attributes(params)

    return if !user_signed_in?
    @comment.vote(have_i_upvoted, have_i_downvoted, current_user.username)

    CommentMailer.send_notifications(@comment)

    @comment.save

    respond_to do |format|
      if @comment.save
        format.json { render action: 'show', status: :created, location: @comment }
      else
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    params = comment_params.dup
    have_i_upvoted = params.delete :have_i_upvoted
    have_i_downvoted = params.delete :have_i_downvoted

    @comment.setup_params(params)

    return if !user_signed_in?
    @comment.vote(have_i_upvoted, have_i_downvoted, current_user.username)

    respond_to do |format|
      if @comment.save
        format.json { render action: 'show', status: :ok, location: @comment }
      else
        format.json { render json: comment.errors, status: :unprocessable_entity }
      end
    end

  end

  def destroy
    @comment = Comment.find(params[:id])
    if current_user == @comment.authored_by
      @comment.deleted_by = current_user
    else
      @comment.muted_by = current_user
    end
    @comment.save
    render action: 'show', status: :ok, location: @comment
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def comment_params
        params.permit(:message,
                      :event_id,
                      :upvotes,
                      :comment,
                      :parent_id,
                      :have_i_downvoted,
                      :have_i_upvoted
        ).merge(authored_by: current_user)
    end
end
