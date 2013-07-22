class RemoveDuplicateAbsentRecords < ActiveRecord::Migration
  def up
    VotingResult.where('voting_session_id = 2329 and updated_at > "2013-06-11 11:17:10" and present = 0').delete_all
    
    Agenda.update_law_vote_results(1)
    AllDelegate.update_vote_counts(1)
  end

  def down
    # do nothing
  end
end
