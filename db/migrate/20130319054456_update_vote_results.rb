class UpdateVoteResults < ActiveRecord::Migration
  def up
    Agenda.not_deleted.laws_only(true).each do |agenda|
      agenda.voting_session.update_results
    end
  end

  def down
    VotingSession.update_all(:result0 => 0, :not_present => 0)
  end
end
