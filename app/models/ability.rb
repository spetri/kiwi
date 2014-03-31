class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.nil?

    can :manage, :all if user.admin?

    can :create, Event
    can :update, Event do |event|
      event.user == user.username
    end
    can :destroy, Event do |event|
      event.user == user.username
    end
  end
end
