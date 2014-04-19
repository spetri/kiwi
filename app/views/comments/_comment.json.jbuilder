comment = @comment if comment.nil?

def json_comment_tree_builder( json, comment_tree_item )
  json.extract! comment_tree_item, :message, :created_at, :updated_at
  json.set! '_id', comment_tree_item._id.to_s
  children = comment_tree_item.children
  unless children.empty?
    json.children do
      json.array! children do |child|
        json_comment_tree_builder( json, child )
      end
    end
  end
end

json.extract! comment, :message, :created_at, :updated_at
json.set! '_id', comment._id.to_s
json.set! :status, comment.status
json.set! :upvotes, comment.upvotes
json.set! :username, comment.authored_by.username
json.set! :replies, json_comment_tree_builder(json, comment)
