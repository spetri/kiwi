require 'spec_helper'

describe Comment do
  before :each do
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
      @comment.new_comment(create(:comment))
      @comment.new_comment(create(:comment))
      @comment.children.length.should == 2
    end

  end

  describe "Setting Comment Statuses" do
    
    it "should have a flagged status" do
      c = create :flagged_comment
      c.status.should == "flagged"
    end

    it "should be deletable" do
      c = create :deleted_comment
      c.status.should == "deleted"
    end

    it "should be hidable" do
      c = create :muted_comment
      c.status.should == "muted"
    end

  end

  describe "Comment Voting" do

    before :each do
      @user = build :user
    end

    it "should upvote comment" do
      @comment.add_upvote(@user)
      @comment.upvote_names[0].should equal(@user)
      @comment.remove_upvote(@user)
      @comment.upvote_names[0].should be_nil
    end

    it "should downvote comment" do
      @comment.add_downvote(@user)
      @comment.downvote_names[0].should equal(@user)
      @comment.remove_downvote(@user)
      @comment.downvote_names[0].should be_nil
    end

    it "was previously upvoted, it should now downvote comment" do
      @comment.add_upvote(@user)
      @comment.upvote_names[0].should equal(@user)
      @comment.remove_upvote(@user)
      @comment.add_downvote(@user)
      @comment.upvote_names[0].should be_nil
      @comment.downvote_names[0].should equal(@user)
    end

    it "was previously downvoted, it should now upvote comment" do
      @comment.add_downvote(@user)
      @comment.downvote_names[0].should equal(@user)
      @comment.remove_downvote(@user)
      @comment.add_upvote(@user)
      @comment.downvote_names[0].should be_nil
      @comment.upvote_names[0].should equal(@user)
    end
    
  end

end
