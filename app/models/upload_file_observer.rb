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
      NotificationTrigger.add_new_file(file.id)
    end
  end

end
