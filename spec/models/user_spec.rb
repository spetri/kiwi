require 'spec_helper'

describe User do
  let(:user) { create :user }

  it 'should be able to get an empty array when the user has no subkasts' do
    expect(User.new.get_my_subkasts).to eq []
  end

  it 'should be able to get the user\'s list of subkast codes' do
    expect(user.get_my_subkasts).to eq ['SE', 'ST']
  end

  it 'should be able to update the user\'s list of subkast codes' do
    user.update_subkasts(['TVM'])
    expect(user.reload.get_my_subkasts).to eq ['TVM']
  end
end
