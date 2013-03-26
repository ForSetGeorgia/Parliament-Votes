class NotificationsController < ApplicationController
#  before_filter :authenticate_user!

	def index
		gon.notifications = true
		msg = []
    if user_signed_in?
  		if request.post?
  			if params[:enable_notifications] && params[:enable_notifications] == 'true'
  				# make sure user is marked as wanting notifications
  				if !current_user.wants_notifications
  					current_user.wants_notifications = true
  					current_user.save
  					msg << I18n.t('app.msgs.notification_yes')
  				end

					# language
					if params[:language]
  					current_user.notification_language = params[:language]
  					current_user.save
  					msg << I18n.t('app.msgs.notification_language', :language => t("app.language.#{params[:language]}"))
					end

          # process file notifications
  				if params[:files_all]
  					# all notifications
  					# delete anything on file first
  					Notification.where(:notification_type => Notification::TYPES[:new_file],
  																					:user_id => current_user.id).delete_all
  					# add all option
  					Notification.create(:notification_type => Notification::TYPES[:new_file],
  																					:user_id => current_user.id)

  					msg << I18n.t('app.msgs.notification_new_file_all_success')
  				else
  					# delete all notifications
  					Notification.where(:notification_type => Notification::TYPES[:new_file],
  																					:user_id => current_user.id).delete_all
  					msg << I18n.t('app.msgs.notification_new_file_none_success')
          end

  			else
  				# indicate user does not want notifications
  				if current_user.wants_notifications
  					current_user.wants_notifications = false
  					current_user.save
  				end

  				# delete any on record
  				Notification.where(:notification_type => Notification::TYPES[:new_file],
  																				:user_id => current_user.id).delete_all

  				msg << I18n.t('app.msgs.notification_no')
  			end
  		end

  		# see if user wants notifications
  		@enable_notifications = current_user.wants_notifications
  		gon.enable_notifications = @enable_notifications

			# get the notfification language
			@language = current_user.notification_language.nil? ? I18n.default_locale.to_s : current_user.notification_language
logger.debug "########## current_user.notification_language = #{current_user.notification_language}"
logger.debug "########## @language = #{@language}"

  		# get new file data to load the form
  		@file_notifications = Notification.where(:notification_type => Notification::TYPES[:new_file],
  																			:user_id => current_user.id)

  		@file_all = false

  		if @file_notifications.present? && @file_notifications.length == 1 && @file_notifications.first.identifier.nil?
				@file_all = true
  		end

  		flash[:notice] = msg.join("<br />").html_safe if !msg.empty?
  	end
	end

end
