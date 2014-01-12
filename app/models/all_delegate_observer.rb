class AllDelegateObserver < ActiveRecord::Observer

  # send notification if a new member has been added
	def after_create(delegate)
		delegate.send_notification = true if delegate.was_processed != true

    # make sure notification is not sent again
    delegate.was_processed = true if delegate.send_notification
	end

	# after delegate has been created, send notification
	def after_commit(delegate)
		if delegate.send_notification
      NotificationTrigger.add_new_delegate(delegate.id)
    end
  end

end
