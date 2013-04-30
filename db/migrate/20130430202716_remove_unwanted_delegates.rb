class RemoveUnwantedDelegates < ActiveRecord::Migration
  def up
    # all delegate ids to delete
    all_delegate_ids = [147, 148, 149, 150, 151, 152, 153, 154, 155]

    # get delegate records with these ids
    puts 'getting delegates'
    delegates = Delegate.where(:all_delegate_id => all_delegate_ids)

    # delete voting records with these delegate ids
    puts 'deleting voting result records'
    voting_results = VotingResult.where(:delegate_id => delegates.map{|x| x.id})
    voting_session_ids = voting_results.map{|x| x.voting_session_id}
    voting_results.delete_all

    # update voting session result fields
    puts 'updating voting session results'
    VotingSession.where(:id => voting_session_ids).each do |vs|
      vs.update_results
    end

    # remove all delegate id from delegate records
    puts 'updating delegate records'
    delegates.update_all(:all_delegate_id => nil)

    # delete all delegate records
    puts 'deleting all delegate records'
    AllDelegate.where(:id => all_delegate_ids).delete_all
  end

  def down
    # do nothing
  end
end
