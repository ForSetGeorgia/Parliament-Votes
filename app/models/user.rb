class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
	# :registerable, :recoverable,
  devise :database_authenticatable,:registerable, :recoverable,
         :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
		:role, :provider, :uid, :nickname, :avatar, :organization_ids, :wants_notifications, :notification_language
	attr_accessor :send_notification

  validates :role, :presence => true

	before_save :check_for_nickname
	before_save :check_for_role
	before_save :set_notification_language

  # - a role with a larger number can do everything that smaller numbers can do
  ROLES = {:user => 0, :process_files => 25, :lower_admin => 50,  :admin => 99}

  # if no nickname supplied, default to name in email before '@'
  def check_for_nickname
    self.nickname = self.email.split('@')[0] if !self.nickname.present? && self.email.present?
  end

	# if no role is supplied, default to the basic user role
	def check_for_role
		self.role = User::ROLES[:user] if !self.role.present?
	end

	# if not set, default to current locale
	def set_notification_language
		self.notification_language = I18n.locale if !self.notification_language.present?
	end

  def notification_language
    read_attribute("notification_language").present? ? read_attribute("notification_language") : I18n.locale.to_s
  end
  
  def self.no_admins
    where("role != ?", ROLES[:admin])
  end

  # get list of roles that user has access to
  # format: [ [name, value] ]
  def accessible_roles
    User::ROLES.select{|k,v| v <= self.role}.map{|key,value| [key.to_s.humanize, value.to_s]}
  end

  # use role inheritence
  def role?(base_role)
    if base_role && ROLES.values.index(base_role)
      return base_role <= self.role
    end
    return false
  end
  
  def role_name
    ROLES.keys[ROLES.values.index(self.role)].to_s
  end
  
	##############################
	## omniauth methods
	##############################
	# get user credentials from omniauth
	def self.from_omniauth(auth)
		x = where(auth.slice(:provider, :uid)).first
		if x.nil?
			x = User.create(:provider => auth.provider, :uid => auth.uid,
											:email => auth.info.email,
											:nickname => auth.info.nickname, :avatar => auth.info.image)
		end
		return x
	end

	# if login fails with omniauth, sessions values are populated with
	# any data that is returned from omniauth
	# this helps load them into the new user registration url
	def self.new_with_session(params, session)
		if session["devise.user_attributes"]
			new(session["devise.user_attributes"], :without_protection => true) do |user|
				user.attributes = params
				user.valid?
			end
		else
			super
		end
	end

	# if user logged in with omniauth, password is not required
	def password_required?
		super && provider.blank?
	end

end
