comment = @comment if comment.nil?

def json_comment_tree_builder( json, comment )
  json.extract! comment, :message, :created_at, :updated_at, :upvotes, :status 
  json.set! '_id', comment._id.to_s
  json.set! :username, comment.authored_by.username unless comment.authored_by.nil?
  json.set! :deleter, comment.deleted_by.username unless comment.deleted_by.nil?
  json.set! :muter, comment.muted_by.username unless comment.muted_by.nil?
  json.set! :parent_id, comment.parent.id.to_s unless comment.parent.nil?
  json.set! :event_id, comment.event.id.to_s
  if user_signed_in?
    json.set! :have_i_upvoted, comment.have_i_upvoted(current_user.username)
    json.set! :have_i_downvoted, comment.have_i_downvoted(current_user.username)
  end
  json.replies comment.children do |reply|
    json_comment_tree_builder( json, reply)
  end
end

json_comment_tree_builder( json, comment )
