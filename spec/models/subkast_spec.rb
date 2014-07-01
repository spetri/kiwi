require 'spec_helper'

describe Subkast do
  before(:each) do
    create :education_subkast
    create :sports_subkast
    create :movies_subkast
  end

  it 'should be able to get all the subkast codes when the user passed in is nil' do
    Subkast.by_user(nil).size.should == 3
  end

  it 'should be able to filter by a user' do
    u = User.new
    u.my_subkasts = ["TVM", "SE"]
    Subkast.by_user(u).size.should == 2
  end
end
