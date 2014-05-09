require 'spec_helper'

describe Comment do
  it "should create comments" do
    c = create :comment
    c.should be_kind_of Comment
    c.event.should be_kind_of Event
    c.status.should == "active"
  end

  it "should have an author" do
    c = create :comment
    c.authored_by.should be_kind_of User
  end

  it "should create trees of comments" do
    root = create :comment
    root.new_comment(create(:comment))
    root.new_comment(create(:comment))
    root.children.length.should == 2
  end

  it "should have a flagged status" do
    c = create :flagged_comment
    c.status.should == "flagged"
  end

  it "should be deletable" do
    c = create :deleted_comment
    c.status.should == "deleted"
  end

  it "should be hidable" do
    c = create :hidden_comment
    c.status.should == "hidden"
  end

  it "should support upvoting comments" do
    c = create :comment
    boring_comment = create :comment, message: 'boring'
    good_comment = create :comment, message: 'good'
    meh_comment = create :comment, message: 'meh'
    c.new_comment(boring_comment)
    c.new_comment(create(:comment, message: 'boring2'))
    c.new_comment(create(:comment, message: 'boring3'))
    c.new_comment(create(:comment, message: 'boring4'))
    c.new_comment(good_comment)
    c.new_comment(meh_comment)
    c.children.first.message.should == "boring"
    meh_comment.upvote(create(:user))
    meh_comment.upvote(create(:user))
    good_comment.upvote(create(:user))
    good_comment.upvote(create(:user))
    good_comment.upvote(create(:user))

    Comment.ordered_by_votes(c.event).first.children.first.message.should == "good"
  end
end
