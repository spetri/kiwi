class CommentsController < ApplicationController

  def show
  end
  
  def create
    @comment = Comment.new(comment_params)
    @comment.event = Event.find(params[:event_id])
    @comment.save
    render action: 'show', status: :created, location: @comment 
  end

  def comment_params
      params.permit(:message,
                    :event_id,
                    :parent_id
      ).merge(authored_by: current_user)
  end

end
