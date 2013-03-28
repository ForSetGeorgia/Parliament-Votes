class VotingResultObserver < ActiveRecord::Observer

  # send notification if the vote was changed
	def after_save(result)
		result.send_notification = true if (result.is_manual_add || result.is_edited) && result.original_vote != result.vote
	end

	# after save, record notification trigger
	def after_commit(result)
		if result.send_notification
      NotificationTrigger.add_change_vote(result.voting_session.agenda_id)
    end
  end

end
