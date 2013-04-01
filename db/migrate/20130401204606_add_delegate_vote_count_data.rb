class AddDelegateVoteCountData < ActiveRecord::Migration
  def up
    AllDelegate.update_vote_count
  end

  def down
    AllDelegate.update_all(:vote_count => 0)
  end
end
