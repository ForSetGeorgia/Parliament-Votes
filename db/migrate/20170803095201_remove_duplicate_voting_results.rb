class RemoveDuplicateVotingResults < ActiveRecord::Migration
  def up
    VotingResult.remove_duplicates
  end

  def down
    puts "do nothing"
  end
end
