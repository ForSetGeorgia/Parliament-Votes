class UploadFileObserver < ActiveRecord::Observer

  # send notification if the file has finished being processed
	def after_save(file)
		file.send_notification = true if file.was_processed != true && file.file_processed == true

    # make sure notification is not sent again
    file.was_processed = true if file.send_notification
	end

	# after file has been created, send notification
	def after_commit(file)
		if file.send_notification && file.conference.present?
		  message = Message.new
		  I18n.available_locales.each do |locale|
				message.bcc = Notification.new_file(locale)
			  if message.bcc.length > 0
				  message.locale = locale
				  message.subject = I18n.t("mailer.notification.new_file.subject", :locale => locale)
				  message.message = I18n.t("mailer.notification.new_file.message", :date => I18n.l(file.conference.start_date, :format => :no_zone), :locale => locale)
				  message.url_id = file.id
				  NotificationMailer.new_file(message).deliver
			  end
		  end
    end
  end

end
