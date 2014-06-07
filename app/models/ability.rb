class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.nil?

    can :manage, :all if user.moderator?

    can :create, Event
    can :update, Event do |event|
      event.user == user.username
    end
    can :destroy, Event do |event|
      event.user == user.username
    end
    can :destroy, Comment do |comment|
      comment.authored_by.username = user.username
    end
  end
end
