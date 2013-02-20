class AddVoteFlag < ActiveRecord::Migration
  def change
    add_column :voting_results, :is_edited, :boolean, :default => false  
    add_column :voting_results, :is_manual_add, :boolean, :default => false  
  end
end
