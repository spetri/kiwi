require 'spec_helper'

describe Comment do
  it "should create comments" do
    c = create :comment
    c.kind_of? Comment
    c.event.kind_of? Event
    c.status.should == "active"
  end

  it "should have an author" do

  end

  it "should create trees of comments" do

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

end
