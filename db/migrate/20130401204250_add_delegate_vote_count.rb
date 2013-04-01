class AddDelegateVoteCount < ActiveRecord::Migration
  def change
    add_column :all_delegates, :vote_count, :integer, :default => 0
    add_index :all_delegates, :vote_count 
  end
end
