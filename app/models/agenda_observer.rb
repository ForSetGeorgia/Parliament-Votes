class AgendaObserver < ActiveRecord::Observer

  # send notification if the agenda/law is now public
	def after_save(agenda)
		agenda.send_notification = true if agenda.was_public != true && agenda.is_public == true

    # make sure notification is not sent again
    agenda.was_public = true if agenda.send_notification
	end

	# send notification
	def after_commit(agenda)
		if agenda.send_notification
      NotificationTrigger.add_law_is_public(agenda.id)
    end
  end


end
