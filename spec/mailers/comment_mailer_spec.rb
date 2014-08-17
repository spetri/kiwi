require 'spec_helper'

describe CommentMailer do
  let(:user1) { create :user }
  let(:user2) { create :user }
  let(:user3) { create :user }
  let(:user4) { _user = create :user
    _user.receive_comment_notifications = false
    _user.save
    return _user
  }

  let(:event1) { create :event, user: user1.username }
  let(:event2) { create :event, user: user4.username }

  let(:comment1) { create :comment, event: event1, authored_by: user2, parent: nil }
  let(:comment2) { create :comment, event: event1, authored_by: user1, parent: nil }
  let(:comment3) { create :comment, event: event2, authored_by: user1, parent: nil }
  let(:comment4) { create :comment, event: event1, authored_by: user4, parent: nil }
  let(:reply1) { create :comment, event: event1, authored_by: user3, parent: comment1 }
  let(:reply2) { create :comment, event: event1, authored_by: user3, parent: comment2 }
  let(:reply3) { create :comment, event: event1, authored_by: user2, parent: comment4 }

  before(:each) do
    ActionMailer::Base.deliveries.reject! { |d| true }
  end

  it 'should send a notice to the owner of the event' do
    CommentMailer.send_notifications(comment1)
    ActionMailer::Base.deliveries.count.should == 1
  end

  it 'should send a notice to the owner of the event and the owner of the comment being replied to' do
    CommentMailer.send_notifications(reply1)
    ActionMailer::Base.deliveries.count.should == 2
  end

  it 'should only send one notice if the comment owner is also the event owner' do
    CommentMailer.send_notifications(reply2)
    ActionMailer::Base.deliveries.count.should == 1
  end

  it 'should not send a notice when the event owner is also the commenter' do
    CommentMailer.send_notifications(comment2)
    ActionMailer::Base.deliveries.count.should == 0
  end

  it 'should not send notifications when the event owner has chosen to ignore notifications' do
    CommentMailer.send_notifications(comment3)
    ActionMailer::Base.deliveries.count.should == 0
  end

  it 'should not send notifications when the comment owner has chosen to ignore notifications' do
    CommentMailer.send_notifications(reply3)
    ActionMailer::Base.deliveries.count.should == 1
  end
end
