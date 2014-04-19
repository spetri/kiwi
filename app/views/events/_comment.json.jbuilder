comment = @comment if comment.nil?
json.extract! comment, :message, :created_at, :updated_at
json.set! '_id', comment._id.to_s
json.set! :status, comment.status
json.set! :upvotes
