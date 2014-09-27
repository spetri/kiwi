class User
  include Mongoid::Document

  attr_accessor :login

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:twitter, :facebook],
         :authentication_keys => [:login]

  ## Database authenticatable
  field :username,              :type => String, :default => ""
  field :email,                 :type => String, :default => ""
  field :encrypted_password,    :type => String, :default => ""

  ## Omniauth
  field :uid,                :type => Integer
  field :provider,           :type => String
  field :name,               :type => String

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  has_many :reminders

  validates :username, uniqueness: true, :length => { :minimum => 3, :maximum => 200 }
  validates :email, uniqueness: true
  validates_format_of :username, :with => /\A[a-zA-Z0-9_]+\z/, :message => "can only contain letters, numbers, and underscores."

  before_create do |user|
    user.defaults
  end

  after_create do |user|
    #TODO: FIXME
    return if Rails.env == "test"
    HipChatNotification.new_user(user)
    if CONFIG['mailchimp_api'].present?
      mc = Mailchimp::API.new(CONFIG['mailchimp_api'])
      mc.lists.subscribe(CONFIG['mailchimp_list_id'], {'email' => email }, {}, 'html', false, true, false, false)
    end
  end

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  ## Forekast
  field :country,                       :type => String

  field :moderator,                     :type => Boolean
  field :receive_comment_notifications, :type => Boolean

  field :my_subkasts,                   :type => Array

  field :last_posted_country,           :type => String

  include Mongoid::Timestamps

  def defaults
    self.receive_comment_notifications = true
    self.my_subkasts = Subkast.pluck('code')
  end

  def get_my_subkasts
    return my_subkasts.present? ? my_subkasts : []
  end

  def update_subkasts(subkast_codes)
    self.my_subkasts = subkast_codes
    self.save
  end

  def login=(login)
    @login = login
  end

  def login
    @login || self.username || self.email
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      self.any_of({ :username =>  /^#{Regexp.escape(login)}$/i }, { :email =>  /^#{Regexp.escape(login)}$/i }).first
    else
      super
    end
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login).downcase
      where(conditions).where('$or' => [ {:username => /^#{Regexp.escape(login)}$/i}, {:email => /^#{Regexp.escape(login)}$/i} ]).first
    else
      where(conditions).first
    end
  end

  def self.omniauth_find(auth)
    where({:provider => auth[:provider], :uid => auth[:uid] } ).first
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def password_required?
    super && provider.blank?
  end

  def email_required?
    super && provider.blank?
  end

  def moderator?
    moderator
  end

  def admin?
    false
  end

end
