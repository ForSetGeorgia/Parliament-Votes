class Notification < ActiveRecord::Base
	belongs_to :user

  attr_accessible :user_id, :notification_type, :identifier
	attr_accessible :email

  validates :user_id, :notification_type, :presence => true

  TYPES = {:new_file => 1, :change_vote => 2, :law_is_public => 3}

	def self.new_file(locale)
		return new_item(TYPES[:new_file], locale)
	end


protected

	def self.new_item(type, locale)
		emails = []
		if type && locale
			x = select("users.email").joins(:user)
			.where("users.wants_notifications = 1 and users.notification_language = ? and notification_type = ?", locale, type)
		end

		if x && !x.empty?
			emails = x.map{|x| x.email}
		end
		return emails
	end

end
