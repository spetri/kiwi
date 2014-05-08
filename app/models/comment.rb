require './lib/kiwi_ordering'
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Tree
  include Mongoid::Tree::Traversal
  include KiwiOrdering
  belongs_to :event
  belongs_to :deleted_by, class_name: 'User'
  belongs_to :hidden_by, class_name: 'User'
  belongs_to :authored_by, class_name: 'User'
  has_and_belongs_to_many :flagged_by, class_name: 'User', inverse_of: nil
  has_and_belongs_to_many :upvoted_by, class_name: 'User', inverse_of: nil
  field :message, type: String
  field :upvotes, type: Integer, default: 0

  def status
    return 'deleted' if deleted_by.kind_of? User
    return 'hidden' if hidden_by.kind_of? User
    return 'flagged' if flagged_by.size > 0
    'active'
  end

  def new_comment(comment)
    comment.parent = self
  end

  def upvote(user)
    upvoted_by << user
    inc :upvotes => 1
    more_votes = siblings.where({:upvotes => upvotes})
    if more_votes.size > 0
      move_up
    else
      move_to_top
    end
    save!
  end

  def self.ordered_by_votes(event)
    where :event => event
  end
end
