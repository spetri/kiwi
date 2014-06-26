require 'spec_helper'

describe Comment do
  before :all do
    @comment = build :comment
  end
  
  describe "Creating and Setting Comments" do

    it "should create comments" do
      @comment.should be_kind_of Comment
      @comment.event.should be_kind_of Event
      @comment.status.should == "active"
    end

    it "should have an author" do
      @comment.authored_by.should be_kind_of User
    end

    it "should create trees of comments" do
      root = @comment
      root.new_comment(create(:comment))
      root.new_comment(create(:comment))
      root.children.length.should == 2
    end

  end

  describe "Setting Comment Statuses" do
    
    it "should have a flagged status" do
      comment = create :flagged_comment
      comment.status.should == "flagged"
    end

    it "should be deletable" do
      comment = create :deleted_comment
      comment.status.should == "deleted"
    end

    it "should be hidable" do
      comment = create :muted_comment
      comment.status.should == "muted"
    end

  end

  describe "Comment Voting" do

    it "should upvote comment" do
      @comment.add_upvote(User)
      @comment.upvote_names[0].should equal(User)
      @comment.remove_upvote(User)
      @comment.upvote_names[0].should be_nil
    end

    it "should downvote comment" do
      @comment.add_downvote(User)
      @comment.downvote_names[0].should equal(User)
      @comment.remove_downvote(User)
      @comment.downvote_names[0].should be_nil
    end

    it "was previously upvoted, it should now downvote comment" do
      @comment.add_upvote(User)
      @comment.upvote_names[0].should equal(User)
      @comment.remove_upvote(User)
      @comment.add_downvote(User)
      @comment.upvote_names[0].should be_nil
      @comment.downvote_names[0].should equal(User)
    end

    it "was previously downvoted, it should now upvote comment" do
      @comment.add_downvote(User)
      @comment.downvote_names[0].should equal(User)
      @comment.remove_downvote(User)
      @comment.add_upvote(User)
      @comment.downvote_names[0].should be_nil
      @comment.upvote_names[0].should equal(User)
    end

  end

end
