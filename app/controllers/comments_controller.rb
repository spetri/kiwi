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

    @comment.message = params[:message]
    @comment.parent_id = params[:parent_id]
    @comment.event_id = params[:event_id]

    @comment.event = Event.find(params[:event_id])
    unless params[:parent_id].nil?
      Comment.find(params[:parent_id]).new_comment @comment
    end

    @comment.update_attributes(params)
    if ( user_signed_in? )
      if ( have_i_upvoted == "true" )
        @comment.add_upvote(current_user.username)
      else
        @comment.remove_upvote(current_user.username)
      end
    end

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

    @comment.message = params[:message]
    @comment.parent_id = params[:parent_id]
    @comment.event_id = params[:event_id]

    return if !user_signed_in?  

    if ( have_i_upvoted )
        @comment.remove_downvote(current_user.username)
        @comment.add_upvote(current_user.username)      
    elsif ( have_i_downvoted )
        @comment.remove_upvote(current_user.username)
        @comment.add_downvote(current_user.username)
    else
      puts "next"
    end

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
    @comment.deleted_by = current_user
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
