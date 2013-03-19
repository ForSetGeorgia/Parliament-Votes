class AddAbstainField < ActiveRecord::Migration
  def change
    add_column :voting_sessions, :result0, :integer, :default => 0
    add_column :voting_sessions, :not_present, :integer, :default => 0

    add_index :voting_sessions, :passed
  end
end
