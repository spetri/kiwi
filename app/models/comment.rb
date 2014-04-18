class Comment
  include Mongoid::Document
  belongs_to :event
  belongs_to :deleted_by, class_name: 'User'
  belongs_to :hidden_by, class_name: 'User'
  belongs_to :authored_by, class_name: 'User'
  has_and_belongs_to_many :flagged_by, class_name: 'User', inverse_of: nil

  def status
    return 'deleted' if deleted_by.kind_of? User
    return 'hidden' if hidden_by.kind_of? User
    return 'flagged' if flagged_by.size > 0
    'active'
  end
end
